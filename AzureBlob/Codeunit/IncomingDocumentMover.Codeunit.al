codeunit 88002 "Incoming Doc To DocAttach"
{
    Subtype = Normal;

    procedure MoveAllIncomingDocsToAttachments(DeleteAfterMove: Boolean)
    var
        IncomingDoc: Record "Incoming Document";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        DocAttachment: Record "Document Attachment";
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
    begin
        if IncomingDoc.FindSet() then
            repeat
                IncomingDocumentAttachment.SetRange("Incoming Document Entry No.", IncomingDoc."Entry No.");
                IncomingDocumentAttachment.SetRange("Main Attachment", true);
                if IncomingDocumentAttachment.FindFirst() then begin
                    if IncomingDoc.GetRecord(RelatedRecord) then begin
                        DataTypeManagement.GetRecordRef(RelatedRecord, RecRef);

                        IncomingDocumentAttachment.GetContent(TempBlob);
                        TempBlob.CreateInStream(InStream);
                        if IncomingDocumentAttachment."Main Attachment" then
                            FileName := IncomingDoc.GetMainAttachmentFileName()
                        else
                            FileName := IncomingDocumentAttachment.GetFullName();


                        InsertAttachment(InStream, RecRef, FileName, true);
                        if DeleteAfterMove then
                            IncomingDocumentAttachment.Delete(false);
                        //end;
                    end;
                end;
            until IncomingDoc.Next() = 0;
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

    procedure MoveSingleIncomingDocsToAttachments(Var IncomingDoc: Record "Incoming Document"; DeleteAfterMove: Boolean)
    var
        //IncomingDoc: Record "Incoming Document";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        DocAttachment: Record "Document Attachment";
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
    begin
        //if InDocAttachment.Get(IncomingDoc."Entry No.") then begin
        IncomingDocumentAttachment.SetRange("Incoming Document Entry No.", IncomingDoc."Entry No.");
        //IncomingDocumentAttachment.SetRange("Main Attachment", true);
        if IncomingDocumentAttachment.FindFirst() then
            repeat
                if IncomingDoc.GetRecord(RelatedRecord) then begin
                    DataTypeManagement.GetRecordRef(RelatedRecord, RecRef);

                    IncomingDocumentAttachment.GetContent(TempBlob);
                    TempBlob.CreateInStream(InStream);
                    if IncomingDocumentAttachment."Main Attachment" then
                        FileName := IncomingDoc.GetMainAttachmentFileName()
                    else
                        FileName := IncomingDocumentAttachment.GetFullName();

                    InsertAttachment(InStream, RecRef, FileName, true);
                    if DeleteAfterMove then
                        IncomingDocumentAttachment.Delete(false);
                    //end;
                end;
            Until IncomingDocumentAttachment.Next() = 0;
    END;

    local procedure InsertAttachment(DocStream: InStream; RecRef: RecordRef; FileName: Text; AllowDuplicateFileName: Boolean)
    var
        IsHandled: Boolean;
        DocAttachment: Record "Document Attachment";
        FileManagement: Codeunit "File Management";
    begin
        if not RecRef.Find() then
            Error(RecordRefNotFoundErr);

        DocAttachment.InitFieldsFromRecRef(RecRef);

        // If duplicate filename is allowed, use increment versions (specifically needed for phone Take/Use Photo functionality)
        if AllowDuplicateFileName then
            IncomingFileName := DocAttachment.FindUniqueFileName(FileManagement.GetFileNameWithoutExtension(FileName), FileManagement.GetExtension(FileName))
        else
            IncomingFileName := FileName;

        DocAttachment.Validate("File Extension", FileManagement.GetExtension(IncomingFileName));
        DocAttachment.Validate("File Name", CopyStr(FileManagement.GetFileNameWithoutExtension(IncomingFileName), 1, MaxStrLen(DocAttachment."File Name")));

        if not IsHandled then begin
            // IMPORTSTREAM(stream,description, mime-type,filename)
            // description and mime-type are set empty and will be automatically set by platform code from the filename
            DocAttachment.ImportFromStream(DocStream, FileName);
            if not DocAttachment.HasContent() then
                Error(NoDocumentAttachedErr);
        end;
        OnBeforeImportWithFilter(DocAttachment, RecRef);
        DocAttachment.Insert(true);
    end;

    procedure OnBeforeImportWithFilter(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
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
