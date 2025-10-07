codeunit 88003 CopyToPostedDoc
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnAfterInsertTransRcptHeader', '', false, false)]
    local procedure OnAfterInsertTransRcptHeader(var TransRcptHeader: Record "Transfer Receipt Header"; var TransHeader: Record "Transfer Header")
    var
        FromRecRef: RecordRef;
        ToRecRef: RecordRef;
        IsHandled: Boolean;
        DocAttachMgt: Codeunit "Document Attachment Mgmt";
    begin
        // Triggered when a posted sales cr. memo / posted sales invoice is created
        if TransHeader.IsTemporary() then
            exit;

        if TransRcptHeader.IsTemporary() then
            exit;

        FromRecRef.GetTable(TransHeader);

        if TransRcptHeader."No." <> '' then
            ToRecRef.GetTable(TransRcptHeader);

        DocAttachMgt.CopyAttachmentsForPostedDocs(FromRecRef, ToRecRef);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Attachment Mgmt", 'OnBeforeCopyAttachmentsForPostedDocsLines', '', false, false)]
    local procedure OnBeforeCopyAttachmentsForPostedDocsLines(var FromRecRef: RecordRef; var ToRecRef: RecordRef; var IsHandled: Boolean)
    begin
        if FromRecRef.Number = 5740 then begin
            IsHandled := true;
            CopyAttachmentsForPostedDocs(FromRecRef, ToRecRef);
        end;
    end;

    procedure CopyAttachmentsForPostedDocs(var FromRecRef: RecordRef; var ToRecRef: RecordRef)
    var
        FromDocumentAttachment: Record "Document Attachment";
        ToDocumentAttachment: Record "Document Attachment";
        FromFieldRef: FieldRef;
        ToFieldRef: FieldRef;
        FromAttachmentDocumentType: Enum "Attachment Document Type";
        FromNo: Code[20];
        ToNo: Code[20];
        IsHandled: Boolean;
    begin
        FromDocumentAttachment.SetRange("Table ID", FromRecRef.Number);
        FromFieldRef := FromRecRef.Field(1);
        FromNo := FromFieldRef.Value();
        FromDocumentAttachment.SetRange("No.", FromNo);

        // Find any attached docs for headers (sales / purchase / service)
        if FromDocumentAttachment.FindSet() then
            repeat
                Clear(ToDocumentAttachment);
                ToDocumentAttachment.Init();
                ToDocumentAttachment.TransferFields(FromDocumentAttachment);
                ToDocumentAttachment.Validate("Table ID", ToRecRef.Number);

                ToFieldRef := ToRecRef.Field(1);
                ToNo := ToFieldRef.Value();
                ToDocumentAttachment.Validate("No.", ToNo);
                Clear(ToDocumentAttachment."Document Type");
                ToDocumentAttachment.Insert(true);
            until FromDocumentAttachment.Next() = 0;

    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnAfterInsertTransShptHeader', '', false, false)]
    local procedure OnAfterInsertTransShptHeader(var TransferHeader: Record "Transfer Header"; var TransferShipmentHeader: Record "Transfer Shipment Header")
    var
        FromRecRef: RecordRef;
        ToRecRef: RecordRef;
        IsHandled: Boolean;
        DocAttachMgt: Codeunit "Document Attachment Mgmt";
    begin
        // Triggered when a posted sales cr. memo / posted sales invoice is created
        if TransferHeader.IsTemporary() then
            exit;

        if TransferShipmentHeader.IsTemporary() then
            exit;

        FromRecRef.GetTable(TransferHeader);

        if TransferShipmentHeader."No." <> '' then
            ToRecRef.GetTable(TransferShipmentHeader);

        DocAttachMgt.CopyAttachmentsForPostedDocs(FromRecRef, ToRecRef);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Attachment Mgmt", 'OnCopyAttachmentsForPostedDocsOnBeforeToDocumentAttachmentInsert', '', true, true)]
    local procedure OnCopyAttachmentsForPostedDocsOnBeforeToDocumentAttachmentInsert(var FromDocumentAttachment: Record "Document Attachment"; var ToDocumentAttachment: Record "Document Attachment")
    var
        ABSBlobClient: codeunit "ABS Blob Client";
        Authorization: Interface "Storage Service Authorization";
        ABSContainersetup: Record "ABS Container Acc setup";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        Instream: InStream;
        Filename: Text;
        RecRef: RecordRef;
        IncDocToDocAttach: Codeunit "Incoming Doc To DocAttach";
        Substrting: Text;
    begin
        if FromDocumentAttachment."File Name" <> '' then begin
            ABSContainersetup.Get;
            Authorization := StorageServiceAuthorization.CreateSharedKey(ABSContainersetup."Shared Access Key");
            ABSBlobClient.Initialize(ABSContainersetup."Account Name", ABSContainersetup."Container Name", Authorization);
            Substrting := '.' + FromDocumentAttachment."File Extension";
            //if Strpos(Rec."Folder Name", Substrting) <> 0 then
            if Strpos(FromDocumentAttachment."Folder Name", Substrting) <> 0 then
                Filename := FromDocumentAttachment."Folder Name"
            else if FromDocumentAttachment."Folder Name" <> '' then
                Filename := FromDocumentAttachment."Folder Name" + '/' + FromDocumentAttachment."File Name" + '.' + FromDocumentAttachment."File Extension"
            else
                Filename := FromDocumentAttachment."File Name" + '.' + FromDocumentAttachment."File Extension";

            //Filename := FromDocumentAttachment."Folder Name" + '/' + FromDocumentAttachment."File Name" + '.' + FromDocumentAttachment."File Extension";
            ABSBlobClient.GetBlobAsStream(Filename, Instream);
            Filename := FromDocumentAttachment."File Name" + '.' + FromDocumentAttachment."File Extension";
            ToDocumentAttachment.ImportFromStream(Instream, FileName);

            //RecRef.Get(ToDocumentAttachment.RecordId);
            IncDocToDocAttach.OnBeforeImportWithFilter(ToDocumentAttachment, RecRef);
            //File.ViewFromStream(Instream, Filename, false);
        end;

    end;

}