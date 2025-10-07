pageextension 88001 "DocAttachment List Factbox Ext" extends "Doc. Attachment List Factbox"
{
    actions
    {
        addafter(OpenInFileViewer)
        {
            action(OpenInFileViewerBlob)
            {
                ApplicationArea = All;
                Caption = 'View Blob';
                Image = View;
                // Enabled = ViewEnabled;
                Scope = Repeater;
                ToolTip = 'View the file. You will be able to download the file from the viewer control. Works only on limited number of file types.';

                trigger OnAction()
                var
                    ABSBlobClient: codeunit "ABS Blob Client";
                    Authorization: Interface "Storage Service Authorization";
                    ABSContainersetup: Record "ABS Container Acc setup";
                    StorageServiceAuthorization: Codeunit "Storage Service Authorization";
                    Instream: InStream;
                    Filename: Text;
                begin
                    if Rec."File Name" <> '' then begin
                        ABSContainersetup.Get;
                        Authorization := StorageServiceAuthorization.CreateSharedKey(ABSContainersetup."Shared Access Key");
                        ABSBlobClient.Initialize(ABSContainersetup."Account Name", ABSContainersetup."Container Name", Authorization);
                        if Strpos(Rec."Folder Name", '.') <> 0 then
                            Filename := Rec."Folder Name"
                        else if Rec."Folder Name" <> '' then
                            Filename := Rec."Folder Name" + '/' + Rec."File Name" + '.' + Rec."File Extension"
                        else
                            Filename := Rec."File Name" + '.' + Rec."File Extension";
                        ABSBlobClient.GetBlobAsStream(Filename, Instream);
                        File.ViewFromStream(Instream, Filename, false);
                    end else
                        Error(CannotDownloadOrViewFileWithEmptyNameErr);
                end;
            }

        }
        addafter(DownloadInRepeater)
        {
            action(DownloadInRepeaterBlob)
            {
                ApplicationArea = All;
                Caption = 'Download Blob';
                Image = Download;
                // Enabled = DownloadEnabled;
                Scope = Repeater;
                ToolTip = 'Download the file to your device. Depending on the file, you will need an app to view or edit the file.';

                trigger OnAction()
                var
                    ABSBlobClient: codeunit "ABS Blob Client";
                    Authorization: Interface "Storage Service Authorization";
                    ABSContainersetup: Record "ABS Container Acc setup";
                    StorageServiceAuthorization: Codeunit "Storage Service Authorization";
                    Filename: Text;
                    Substrting: Text;
                begin
                    ABSContainersetup.Get;
                    Authorization := StorageServiceAuthorization.CreateSharedKey(ABSContainersetup."Shared Access Key");
                    ABSBlobClient.Initialize(ABSContainersetup."Account Name", ABSContainersetup."Container Name", Authorization);
                    Substrting := '.' + Rec."File Extension";
                    if Strpos(Rec."Folder Name", Substrting) <> 0 then
                        Filename := Rec."Folder Name"
                    else if Rec."Folder Name" <> '' then
                        Filename := Rec."Folder Name" + '/' + Rec."File Name" + '.' + Rec."File Extension"
                    else
                        Filename := Rec."File Name" + '.' + Rec."File Extension";

                    ABSBlobClient.GetBlobAsFile(Filename);
                end;
            }
        }
    }
    var
        CannotDownloadOrViewFileWithEmptyNameErr: Label 'The file must have a name.';
        AzureContainerMgmt: Codeunit AttachedDocuments;
}
