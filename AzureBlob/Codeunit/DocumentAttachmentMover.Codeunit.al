codeunit 88005 "Doc Attach To BlobStorage"
{
    Subtype = Normal;
    Permissions = tabledata "Tenant Media" = RIMD;
    trigger OnRun()
    var
        myInt: Integer;
    begin
        MoveAllIncomingDocAttachtoBlobStorage(true);
    end;

    procedure MoveAllIncomingDocAttachtoBlobStorage(DeleteAfterMove: Boolean)
    var
        DocumentAttachment: Record "Document Attachment";
        DocAttachment: Record "Document Attachment";
        DocAttachment1: Record "Document Attachment";
        TempTenantMedia: Record "Tenant Media" temporary;
        TempDocAttach: Record "Document Attachment" temporary;
        RecRef: RecordRef;
        NoFieldRef: FieldRef;
        DocNo: Code[20];
        InStream: InStream;
        FileName: Text[250];
        NextLineNo: Integer;
        DocAttachMgt: Codeunit "Document Attachment Mgmt";
        SalesOrder: Page "Sales Order";
        RelatedRecord: Variant;
        DataTypeManagement: Codeunit "Data Type Management";
        TempBlob: Codeunit "Temp Blob";
        TenantMedia: Record "Tenant Media";
        MediaCount: Integer;
    begin
        MediaCount := 0;
        TempTenantMedia.DeleteAll();
        DocAttachment.SetRange("Moved Attachment", false);
        if DocAttachment.FindSet() then
            repeat
                TempDocAttach.DeleteAll();
                if Not DocAttachment.HasContent() then begin
                    ;

                    DocAttachment1 := DocAttachment;
                    DocAttachment1."Moved Attachment" := true;
                    DocAttachment1.Modify();
                    continue;
                end;
                if Not TenantMedia.Get(DocAttachment."Document Reference ID".MediaId()) then begin

                    DocAttachment1 := DocAttachment;
                    DocAttachment1."Moved Attachment" := true;
                    DocAttachment1.Modify();
                    continue;
                end;

                MediaCount += 1;
                DocAttachment.GetAsTempBlob(TempBlob);
                TempBlob.CreateInStream(InStream);
                FileName := DocAttachment."File Name" + '.' + DocAttachment."File Extension";
                TenantMedia.Get(DocAttachment."Document Reference ID".MediaId());
                TempTenantMedia := TenantMedia;
                if TempTenantMedia.Insert then;
                TempDocAttach := DocAttachment;
                InsertAttachment(TempDocAttach, InStream, RecRef, FileName, true);
                DocAttachment1 := DocAttachment;
                DocAttachment1.Delete(true);
            until (DocAttachment.Next() = 0) or (MediaCount = 200);
        if TempTenantMedia.Findfirst() then
            repeat
                if TenantMedia.Get(TempTenantMedia.ID) then
                    TenantMedia.Delete(true);
            Until TempTenantMedia.Next() = 0;
    end;

    local procedure GetNextLineNo(TableId: Integer; DocNo: Code[20]): Integer
    var
        DocAttachment: Record "Document Attachment";
    begin
        DocAttachment.SetRange("Table ID", TableId);
        DocAttachment.SetRange("No.", DocNo);
        if DocAttachment.FindLast() then
            exit(DocAttachment."Line No." + 10000)
        else
            exit(10000);
    end;

    procedure MoveSingleDocAttchmentToBlobStorage(Var DocAttachment: Record "Document Attachment"; DeleteAfterMove: Boolean)
    var
        //IncomingDoc: Record "Incoming Document";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        DocAttachment1: Record "Document Attachment";
        RecRef: RecordRef;
        NoFieldRef: FieldRef;
        DocNo: Code[20];
        InStream: InStream;
        FileName: Text[250];
        NextLineNo: Integer;
        DocAttachMgt: Codeunit "Document Attachment Mgmt";
        SalesOrder: Page "Sales Order";
        RelatedRecord: Variant;
        DataTypeManagement: Codeunit "Data Type Management";
        TempBlob: Codeunit "Temp Blob";
        TempDocAttach: Record "Document Attachment" temporary;
        TenantMedia: Record "Tenant Media";
        MediaID: Guid;

    begin
        //if InDocAttachment.Get(IncomingDoc."Entry No.") then begin
        TempDocAttach.DeleteAll();
        if Not DocAttachment.HasContent() then
            exit;
        DocAttachment.GetAsTempBlob(TempBlob);
        TempBlob.CreateInStream(InStream);
        FileName := DocAttachment."File Name" + '.' + DocAttachment."File Extension";
        MediaID := DocAttachment."Document Reference ID".MediaId();
        TempDocAttach := DocAttachment;
        InsertAttachment(TempDocAttach, InStream, RecRef, FileName, true);

        DocAttachment.Delete(true);
        IF TenantMedia.Get(MediaID) then
            TenantMedia.Delete();
    END;

    local procedure InsertAttachment(TempDocAttachment: Record "Document Attachment" temporary; DocStream: InStream; RecRef: RecordRef; FileName: Text; AllowDuplicateFileName: Boolean)
    var
        IsHandled: Boolean;
        DocAttachment: Record "Document Attachment";
        FileManagement: Codeunit "File Management";
    begin
        //if not RecRef.Find() then
        //  Error(RecordRefNotFoundErr);

        //DocAttachment.InitFieldsFromRecRef(RecRef);
        DocAttachment.Init();
        DocAttachment.VALIDATE("Table ID", TempDocAttachment."Table ID");
        DocAttachment."No." := TempDocAttachment."No.";
        DocAttachment."File Type" := TempDocAttachment."File Type";
        DocAttachment."Attached Date" := TempDocAttachment."Attached Date";
        DocAttachment."File Extension" := TempDocAttachment."File Extension";
        DocAttachment."File Name" := TempDocAttachment."File Name";
        DocAttachment."Document Reference ID" := TempDocAttachment."Document Reference ID";
        DocAttachment."Attached By" := TempDocAttachment."Attached By";
        DocAttachment."Document Flow Production" := TempDocAttachment."Document Flow Production";
        DocAttachment."Document Flow Purchase" := TempDocAttachment."Document Flow Purchase";
        DocAttachment."Document Flow Sales" := TempDocAttachment."Document Flow Sales";
        DocAttachment."Document Flow Service" := TempDocAttachment."Document Flow Service";
        DocAttachment."Line No." := TempDocAttachment."Line No.";
        DocAttachment."Document Type" := TempDocAttachment."Document Type";
        DocAttachment."VAT Report Config. Code" := TempDocAttachment."VAT Report Config. Code";
        DocAttachment."Moved Attachment" := true;
        IncomingFileName := FileName;
        if not IsHandled then begin
            DocAttachment.ImportFromStream(DocStream, FileName);
            if not DocAttachment.HasContent() then
                Error(NoDocumentAttachedErr);
        end;
        OnBeforeImportWithFilter(DocAttachment);
        DocAttachment.Insert(true);
    end;

    procedure OnBeforeImportWithFilter(var DocumentAttachment: Record "Document Attachment")
    var
        ABSBlobClient: codeunit "ABS Blob Client";
        Authorization: Interface "Storage Service Authorization";
        ABSContainersetup: Record "ABS Container Acc setup";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        InS: InStream;
        OutS: OutStream;
        tempBlob: Codeunit "Temp Blob";
        Filename: Text;
        ABSContainerClient: Codeunit "ABS Container Client";
        Containername: Text[250];
        AzureContainerMgmt: Codeunit AzureContainermgmt;
        AttachedDocuments: Codeunit AttachedDocuments;
        OldFileName: Text;
    begin

        ABSContainersetup.Get;
        if ABSContainersetup."Enable Container Setup" then begin
            Containername := ABSContainersetup."Container Name";
            if Not AzureContainerMgmt.FindAzureContainer(Containername) then begin
                AzureContainerMgmt.CreatAzureContainer(Containername);
            end;
            Authorization := StorageServiceAuthorization.CreateSharedKey(ABSContainersetup."Shared Access Key");
            ABSBlobClient.Initialize(ABSContainersetup."Account Name", Containername, Authorization);
            //Copy from outstream to instream
            tempBlob.CreateOutStream(OutS);
            DocumentAttachment."Document Reference ID".ExportStream(OutS);
            DocumentAttachment."Folder Name" := AttachedDocuments.GetFolderName(DocumentAttachment."Table ID", DocumentAttachment."Document Type", DocumentAttachment);
            OldFileName := DocumentAttachment."File Name";
            DocumentAttachment."File Name" := AttachedDocuments.GetFileName(DocumentAttachment."Table ID", DocumentAttachment."Document Type", DocumentAttachment, DocumentAttachment."File Name");
            if DocumentAttachment."File Name" = '' then
                DocumentAttachment."File Name" := OldFileName;
            tempBlob.CreateInStream(InS);
            if DocumentAttachment."Folder Name" <> '' then
                Filename := DocumentAttachment."Folder Name" + '/' + DocumentAttachment."File Name" + '.' + DocumentAttachment."File Extension"
            else
                Filename := DocumentAttachment."File Name";
            ABSBlobClient.PutBlobBlockBlobStream(Filename, InS);
        end;
    end;


    var
        IncomingFileName: Text;
        NoDocumentAttachedErr: Label 'Please attach a document first.';
        EmptyFileNameErr: Label 'Please choose a file to attach.';
        NoContentErr: Label 'The selected file ''%1'' has no content. Please choose another file.', Comment = '%1=FileName';
        DuplicateErr: Label 'This file is already attached to the document. Please choose another file.';
        RecordRefNotFoundErr: Label 'The record reference is empty. Please save the record before attaching files.';


}
