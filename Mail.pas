unit Mail;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, EAGetMailObjLib_TLB;

type GetMail = class
  public
    function FindFolder(folderPath: WideString; folders: IFolderCollection) :IImap4Folder;
    procedure RetrieveMail(server: WideString; user: WideString; password: WideString; useSslConnection: Boolean = true);
end;

const
    MailServerImap4 = 1;
    MailServerPop3 = 0;
    MailServerEWS = 2;
    MailServerDAV = 3;

implementation

function GetMail.FindFolder(folderPath: WideString; folders: IFolderCollection) :IImap4Folder;
var
    i: integer;
    folder: IImap4Folder;
begin
    for i:= 0 to folders.Count - 1 do
        begin
            folder := folders.Item[i];
            if CompareText(folder.LocalPath, folderPath) = 0 then
                begin
                    result := folder;
                    exit;
                end;

            // Search folder in sub-folders
            folder := FindFolder(folderPath, folder.SubFolderList);
            if not (folder = nil) then
                begin
                    result := folder;
                    exit;
                end;
        end;

    // No folder found
    result := nil;
end;

procedure GetMail.RetrieveMail(server: WideString; user: WideString; password: WideString; useSslConnection: Boolean = true);
var
    oServer: TMailServer;
    oClient: TMailClient;
    oTools: TTools;
    folders: IFolderCollection;
    oFolder: IImap4Folder;
    infos: IMailInfoCollection;
    attachments: IAttachmentCollection;
    oInfo: IMailInfo;
    oAttachment: IAttachment;
    oMail: IMail;
    localInbox, attachmentName, attachmentFolder: WideString;
    strInfo : String;
    i, j: Integer;
begin
    try
        if server = 'gmail' then
          begin server := 'imap.gmail.com';  end
        else
          begin server := 'imap-mail.outlook.com'; end;


        // set current thread code page to system default code page.
        SetThreadLocale(GetSystemDefaultLCID());
        oTools := TTools.Create(Application);

        // Create a folder named "inbox" under
        // current directory to store the email files
        localInbox := GetCurrentDir() + '\inbox';
        oTools.CreateFolder(localInbox);

        oServer := TMailServer.Create(Application);
        oServer.Server := server;
        oServer.User := user;
        oServer.Password := password;
        oServer.Protocol := MailServerImap4;

        // Enable SSL/TLS Connection, most modern email server require SSL/TLS connection by default.
        oServer.SSLConnection := useSslConnection;

        if useSslConnection then
          begin
              // Set 993 SSL IMAP port
              oServer.Port := 993;
          end
        else
          begin
              // Set 143 IMAP port
              oServer.Port := 143;
          end;

        oClient := TMailClient.Create(Application);
        oClient.LicenseCode := 'TryIt';

        oClient.Connect1(oServer.DefaultInterface);
        //ShowMessage('Connected!');

        // get folder list
        folders := oClient.GetFolderList();

        // find source folder.
        oFolder := FindFolder('Berlys', folders);
        if oFolder = nil then
            raise Exception.Create('No source folder found!');
        // select "source" folder, GetMailInfoList returns the mail list in selected folder.
        oClient.SelectFolder(oFolder);
        //ShowMessage(oClient.SelectedFolder + ' is selected!');


        oClient.GetMailInfosParam.SubjectContains := 'Volumen Rutas';
        //oClient.GetMailInfosParam.SenderContains = "support"
        oClient.GetMailInfosParam.DateRangeSINCE := StrToDate('01/05/2019');
        oClient.GetMailInfosParam.DateRangeBEFORE := StrToDate('01/03/2020') ;

        infos := oClient.GetMailInfoList();
        for i := infos.Count - 1 downto 0 do
            begin
                oInfo := infos.Item[i];
               // Receive email from server
                oMail := oClient.GetMail(oInfo);
                DateTimeToString(strInfo, 'd/m/y', oMail.SentDate);
                //strInfo := Format('From: %s\nSubject: %s\n Sent Date: %s', [oMail.From.Address, oMail.Subject, strInfo]);
                //ShowMessage(strInfo.Replace('\n', #13#10));
                // Parse attachment
                attachmentFolder := 'attachments';
                attachments := oMail.AttachmentList;
                if(attachments.Count > 0) then
                    begin
                        // Create a temporal folder to store attachments.
                        if not oTools.ExistFile(attachmentFolder) then
                            oTools.CreateFolder(attachmentFolder);

                        for j := 0 to attachments.Count - 1 do
                           begin
                                oAttachment := attachments.Item[j];
                                DateTimeToString(strInfo, 'yyyy-mm-dd', oMail.SentDate);
                                attachmentName := Format('%s\%s_%s', [attachmentFolder, strInfo, oAttachment.Name]);
                                oAttachment.SaveAs(attachmentName, true);
                           end;
                    end;
            end;

        // Delete method just mark the email as deleted,
        // Quit method expunge the emails from server permanently.
        oClient.Quit;
        showmessage('S''han descarregat els fitxers adjunts.');

    except
        on ep:Exception do
            ShowMessage('Error: ' + ep.Message);
    end;
end;

end.
