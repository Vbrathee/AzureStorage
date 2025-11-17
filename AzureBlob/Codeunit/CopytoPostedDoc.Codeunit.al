codeunit 88003 CopyToPostedDoc
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterCustLedgEntryInsert', '', false, false)]
    local procedure OnAfterCustLedgEntryInsert(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"; var DtldLedgEntryInserted: Boolean; PreviewMode: Boolean)
    Var
        DocAttachment: Record "Document Attachment";
        FromRecRef: RecordRef;
        ToRecRef: RecordRef;
        IsHandled: Boolean;
        DocAttachMgt: Codeunit "Document Attachment Mgmt";

    begin
        if GenJournalLine.IsTemporary() then
            exit;

        if CustLedgerEntry.IsTemporary() then
            exit;

        FromRecRef.GetTable(GenJournalLine);

        if CustLedgerEntry."Entry No." <> 0 then
            ToRecRef.GetTable(CustLedgerEntry);

        DocAttachMgt.CopyAttachmentsForPostedDocs(FromRecRef, ToRecRef);

    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterVendLedgEntryInsert', '', false, false)]
    local procedure OnAfterVendLedgEntryInsert(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"; var DtldLedgEntryInserted: Boolean; PreviewMode: Boolean)
    Var
        DocAttachment: Record "Document Attachment";
        FromRecRef: RecordRef;
        ToRecRef: RecordRef;
        IsHandled: Boolean;
        DocAttachMgt: Codeunit "Document Attachment Mgmt";

    begin
        if GenJournalLine.IsTemporary() then
            exit;

        if VendorLedgerEntry.IsTemporary() then
            exit;

        FromRecRef.GetTable(GenJournalLine);

        if VendorLedgerEntry."Entry No." <> 0 then
            ToRecRef.GetTable(VendorLedgerEntry);

        DocAttachMgt.CopyAttachmentsForPostedDocs(FromRecRef, ToRecRef);

    end;
    //OnAfterGLFinishPosting
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterGLFinishPosting', '', false, false)]
    local procedure OnAfterGLFinishPosting(GLEntry: Record "G/L Entry"; var GenJnlLine: Record "Gen. Journal Line"; var IsTransactionConsistent: Boolean; FirstTransactionNo: Integer; var GLRegister: Record "G/L Register"; var TempGLEntryBuf: Record "G/L Entry" temporary; var NextEntryNo: Integer; var NextTransactionNo: Integer)
    Var
        DocAttachment: Record "Document Attachment";
        FromRecRef: RecordRef;
        ToRecRef: RecordRef;
        IsHandled: Boolean;
        DocAttachMgt: Codeunit "Document Attachment Mgmt";

    begin
        if GenJnlLine.IsTemporary() then
            exit;

        if GLEntry.IsTemporary() then
            exit;

        FromRecRef.GetTable(GenJnlLine);

        if GLEntry."Entry No." <> 0 then
            ToRecRef.GetTable(GLEntry);

        DocAttachMgt.CopyAttachmentsForPostedDocs(FromRecRef, ToRecRef);

    end;


    /*     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitGLEntry', '', false, false)]
        local procedure OnAfterInitGLEntry(var GLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line"; Amount: Decimal; AddCurrAmount: Decimal; UseAddCurrAmount: Boolean; var CurrencyFactor: Decimal; var GLRegister: Record "G/L Register")
        Var
            DocAttachment: Record "Document Attachment";
            FromRecRef: RecordRef;
            ToRecRef: RecordRef;
            IsHandled: Boolean;
            DocAttachMgt: Codeunit "Document Attachment Mgmt";

        begin
            if GenJournalLine.IsTemporary() then
                exit;

            if GLEntry.IsTemporary() then
                exit;

            FromRecRef.GetTable(GenJournalLine);

            if GLEntry."Entry No." <> 0 then
                ToRecRef.GetTable(GLEntry);

            DocAttachMgt.CopyAttachmentsForPostedDocs(FromRecRef, ToRecRef);

        end;
     */
    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnGenJnlLineAfterDelete(var Rec: Record "Gen. Journal Line")
    var
        AttachedDocuments: Codeunit AttachedDocuments;
        RecRef: RecordRef;
        FieldNo: Integer;
        FieldRef: FieldRef;
        DocumentAttachment: Record "Document Attachment";
        TemplateName: Code[10];
        BatchName: Code[10];
        LineNo: Integer;
    begin
        // Your logic here
        RecRef.GetTable(Rec);
        DocumentAttachment.SetRange("Table ID", RecRef.Number);


        if AttachedDocuments.TableHasTemplateNamePrimaryKey(RecRef.Number(), FieldNo) then begin
            FieldRef := RecRef.Field(FieldNo);
            TemplateName := FieldRef.Value();
            DocumentAttachment.Validate("Journal Template Name", TemplateName);
        end;

        if AttachedDocuments.TableHasBatchNamePrimaryKey(RecRef.Number(), FieldNo) then begin
            FieldRef := RecRef.Field(FieldNo);
            BatchName := FieldRef.Value();
            DocumentAttachment.Validate("Journal Batch Name", BatchName);
        end;
        if AttachedDocuments.TableHasLineNumberPrimaryKey(RecRef.Number(), FieldNo) then begin
            FieldRef := RecRef.Field(FieldNo);
            LineNo := FieldRef.Value();
            DocumentAttachment.Validate("Line No.", LineNo);
        end;
        if DocumentAttachment.FindSet() then
            DocumentAttachment.DeleteAll(true);

    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnAfterInsertTransRcptHeader', '', false, false)]
    local procedure OnAfterInsertTransRcptHeader(var TransRcptHeader: Record "Transfer Receipt Header"; var TransHeader: Record "Transfer Header")
    var
        FromRecRef: RecordRef;
        ToRecRef: RecordRef;
        IsHandled: Boolean;
        DocAttachMgt: Codeunit "Document Attachment Mgmt";
    //        GenJnlPost: Codeunit "Gen. Jnl.-Post Line";
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


    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnAfterInitFieldsFromRecRef', '', false, false)]
    local procedure OnAfterInitFieldsFromRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        AttachedDocuments: Codeunit AttachedDocuments;
        FieldNo: Integer;
        FieldRef: FieldRef;
        LedgerEntryNo: Integer;
        BatchName: Code[10];
        TemplateName: Code[10];
        LineNo: Integer;
    begin
        if AttachedDocuments.TableHasEntryNoPrimaryKey(RecRef.Number(), FieldNo) then begin
            FieldRef := RecRef.Field(FieldNo);
            LedgerEntryNo := FieldRef.Value();
            DocumentAttachment.Validate("Ledger Entry No.", LedgerEntryNo);
        end;
        if AttachedDocuments.TableHasTemplateNamePrimaryKey(RecRef.Number(), FieldNo) then begin
            FieldRef := RecRef.Field(FieldNo);
            TemplateName := FieldRef.Value();
            DocumentAttachment.Validate("Journal Template Name", TemplateName);
        end;

        if AttachedDocuments.TableHasBatchNamePrimaryKey(RecRef.Number(), FieldNo) then begin
            FieldRef := RecRef.Field(FieldNo);
            BatchName := FieldRef.Value();
            DocumentAttachment.Validate("Journal Batch Name", BatchName);
        end;
        if AttachedDocuments.TableHasLineNumberPrimaryKey(RecRef.Number(), FieldNo) then begin
            FieldRef := RecRef.Field(FieldNo);
            LineNo := FieldRef.Value();
            DocumentAttachment.Validate("Line No.", LineNo);
        end;

    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Attachment Mgmt", 'OnBeforeCopyAttachmentsForPostedDocsLines', '', false, false)]
    local procedure OnBeforeCopyAttachmentsForPostedDocsLines(var FromRecRef: RecordRef; var ToRecRef: RecordRef; var IsHandled: Boolean)
    begin
        if FromRecRef.Number = 5740 then begin
            IsHandled := true;
            CopyAttachmentsForPostedDocs(FromRecRef, ToRecRef);

        end;
        if FromRecRef.Number in [Database::"Gen. Journal Line", Database::"Cust. Ledger Entry", Database::"Vendor Ledger Entry"] then begin
            IsHandled := true;
            CopyAttachmentFromGenJnlLine(FromRecRef, ToRecRef);
        end;
    end;

    local procedure CopyAttachmentFromGenJnlLine(Var FromRecRef: RecordRef; var ToRecRef: RecordRef)
    var
        FromDocumentAttachment: Record "Document Attachment";
        ToDocumentAttachment: Record "Document Attachment";
        FromFieldRef: FieldRef;
        ToFieldRef: FieldRef;
        FromAttachmentDocumentType: Enum "Attachment Document Type";
        FromNo: Code[20];
        ToNo: Integer;
        AttachedDocument: Codeunit AttachedDocuments;
        FieldNo: Integer;
        LineNo: Integer;
        BatchName: Code[10];
        TemplateName: Code[10];
        Fieldref: FieldRef;
        GenledgEntry: Page "General Ledger Entries";
        GeneralJournal: Record "Gen. Journal Line";
    begin
        FromDocumentAttachment.SetRange("Table ID", FromRecRef.Number);
        if AttachedDocument.TableHasLineNumberPrimaryKey(FromRecRef.Number, FieldNo) then begin
            FieldRef := FromRecRef.Field(FieldNo);
            LineNo := Fieldref.Value;
            FromDocumentAttachment.SetRange("Line No.", LineNo);
        end;
        if AttachedDocument.TableHasBatchNamePrimaryKey(FromRecRef.Number, FieldNo) then begin
            FieldRef := FromRecRef.Field(FieldNo);
            BatchName := Fieldref.Value;
            FromDocumentAttachment.SetRange("Journal Batch Name", BatchName);
        end;
        if AttachedDocument.TableHasTemplateNamePrimaryKey(FromRecRef.Number, FieldNo) then begin
            FieldRef := FromRecRef.Field(FieldNo);
            TemplateName := Fieldref.Value;
            FromDocumentAttachment.SetRange("Journal Template Name", TemplateName);
        end;
        if FromDocumentAttachment.FindSet() then
            repeat
                /*                 Clear(ToDocumentAttachment);
                                ToDocumentAttachment.Init();
                                ToDocumentAttachment.TransferFields(FromDocumentAttachment);
                                ToDocumentAttachment.Validate("Table ID", ToRecRef.Number);

                                ToFieldRef := ToRecRef.Field(1);
                                ToNo := ToFieldRef.Value();
                                ToDocumentAttachment.Validate("Ledger Entry No.", ToNo);
                                ToDocumentAttachment.ID := ToDocumentAttachment."Ledger Entry No.";
                                Clear(ToDocumentAttachment."Document Type");

                                IF ToDocumentAttachment.Insert(true) then;

                 */
                CopyDocAttachmenttoPostedDoc(FromDocumentAttachment, ToDocumentAttachment, ToRecRef)
            until FromDocumentAttachment.Next() = 0;
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

    local procedure CopyDocAttachmenttoPostedDoc(var FromDocumentAttachment: Record "Document Attachment"; var ToDocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        ABSBlobClient: codeunit "ABS Blob Client";
        Authorization: Interface "Storage Service Authorization";
        ABSContainersetup: Record "ABS Container Acc setup";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        Instream: InStream;
        Filename: Text;

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
            // Filename := FromDocumentAttachment."File Name" + '.' + FromDocumentAttachment."File Extension";
            ToDocumentAttachment.InsertAttachmentGL(Instream, RecRef, Filename, true);
            //ToDocumentAttachment.ImportFromStream(Instream, FileName);
            //ToDocumentAttachment.Insert(true);

            //RecRef.Get(ToDocumentAttachment.RecordId);
            //     IncDocToDocAttach.OnBeforeImportWithFilter(ToDocumentAttachment, RecRef);
            //File.ViewFromStream(Instream, Filename, false);
        end;
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