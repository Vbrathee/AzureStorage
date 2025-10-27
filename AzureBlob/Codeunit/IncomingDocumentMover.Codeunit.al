codeunit 88002 "Incoming Doc To DocAttach"
{
    Subtype = Normal;

    trigger OnRun()
    var
        myInt: Integer;
    begin
        MoveAllIncomingDocsToAttachments(true);
    end;

    procedure MoveAllIncomingDocsToAttachments(DeleteAfterMove: Boolean)
    var
        IncomingDoc: Record "Incoming Document";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        IncomingDocumentAttachment1: Record "Incoming Document Attachment";
        DocAttachment: Record "Document Attachment";
        RecRef: RecordRef;
        NoFieldRef: FieldRef;
        DocNo: Code[20];
        InStream: InStream;
        FileName: Text[250];
        NextLineNo: Integer;
        DocAttachMgt: Codeunit "Document Attachment Mgmt";
        IncDocAttachOverview: Record "Inc. Doc. Attachment Overview";
        SalesOrder: Page "Sales Order";
        RelatedRecord: Variant;
        PostedInStream: InStream;
        IncomingDoc1: Record "Incoming Document";

        DataTypeManagement: Codeunit "Data Type Management";
        TempBlob: Codeunit "Temp Blob";
        PostedRecRef: RecordRef;
        MediaCount: Integer;
        EncodingType: TextEncoding;
        IncomingDocAttach: Page 194;

    begin
        MediaCount := 0;
        if IncomingDoc.FindSet() then
            repeat
                IncomingDocumentAttachment.SetRange("Incoming Document Entry No.", IncomingDoc."Entry No.");
                //IncomingDocumentAttachment.SetRange("Main Attachment", true);
                if IncomingDocumentAttachment.FindFirst() then begin
                    repeat
                        if IncomingDocumentAttachment.Content.HasValue then begin

                            if IncomingDoc.GetRecord(RelatedRecord) then begin
                                MediaCount += 1;
                                DataTypeManagement.GetRecordRef(RelatedRecord, RecRef);

                                //IncomingDocumentAttachment.GetContent(TempBlob);
                                //TempBlob.CreateInStream(InStream);
                                IncomingDocumentAttachment.CalcFields(Content);

                                IncomingDocumentAttachment.Content.CreateInStream(InStream, EncodingType::MSDos);
                                IncomingDocumentAttachment.Content.CreateInStream(PostedInStream, EncodingType::MSDos);
                                if IncomingDocumentAttachment."Main Attachment" then
                                    FileName := IncomingDoc.GetMainAttachmentFileName()
                                else
                                    FileName := IncomingDocumentAttachment.GetFullName();


                                InsertAttachment(InStream, RecRef, FileName, true);
                                if IncomingDoc.Posted and (IncomingDoc."Document No." <> '') then begin
                                    PostedRecRef := DetectPostedDocumentAsRecordRef(IncomingDoc."Document No.", IncomingDoc."Posting Date");
                                    if PostedRecRef.Number <> 0 then
                                        InsertAttachment(PostedInStream, PostedRecRef, FileName, true);
                                end;
                                if DeleteAfterMove then begin
                                    IncomingDocumentAttachment1 := IncomingDocumentAttachment;
                                    IncomingDocumentAttachment.Delete(false);
                                end;
                                Commit();
                                //end;
                            end;
                        end;
                    Until IncomingDocumentAttachment.Next() = 0;
                end;
                if DeleteAfterMove then begin
                    IncomingDoc1 := IncomingDoc;
                    IncomingDoc1.Delete(false);
                end;

            until (IncomingDoc.Next() = 0) or (MediaCount >= 3000);
    end;

    local procedure GetNextLineNo(TableId: Integer;
DocNo: Code[20]): Integer
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
        IncomingDocumentAttachment1: Record "Incoming Document Attachment";

        RecRef: RecordRef;
        NoFieldRef: FieldRef;
        DocNo: Code[20];
        InStream: InStream;
        FileName: Text[250];
        NextLineNo: Integer;
        DocAttachMgt: Codeunit "Document Attachment Mgmt";
        PostedSalesInvoice: Page "Posted Sales Invoice";
        SalesOrder: Page "Sales Order";
        PostedInStream: InStream;
        IncomingDoc1: Record "Incoming Document";
        PostedRecRef: RecordRef;
        RelatedRecord: Variant;
        DataTypeManagement: Codeunit "Data Type Management";
        TempBlob: Codeunit "Temp Blob";
        EncodingType: TextEncoding;
        OutStream: OutStream;
        SourceInStream: InStream;
        HeaderHex: Text[256];
    begin
        //if InDocAttachment.Get(IncomingDoc."Entry No.") then begin
        IncomingDocumentAttachment.SetRange("Incoming Document Entry No.", IncomingDoc."Entry No.");
        //IncomingDocumentAttachment.SetRange("Main Attachment", true);
        if IncomingDocumentAttachment.FindFirst() then
            repeat
                if Not IncomingDocumentAttachment.Content.HasValue then
                    continue;
                if IncomingDoc.GetRecord(RelatedRecord) then begin

                    DataTypeManagement.GetRecordRef(RelatedRecord, RecRef);
                    IncomingDocumentAttachment.CalcFields(Content);
                    //                  MESSAGE('%1', IncomingDocumentAttachment.Content.Length());

                    IncomingDocumentAttachment.Content.CreateInStream(SourceInStream, EncodingType::MSDos);
                    IncomingDocumentAttachment.Content.CreateInStream(PostedInStream, EncodingType::MSDos);

                    // Copy source into TempBlob (safe buffer)
                    //TempBlob.CreateOutStream(OutStream);
                    //CopyStream(OutStream, SourceInStream);

                    // Read header for diagnostics
                    //     TempBlob.CreateInStream(SourceInStream);

                    //   IncomingDocumentAttachment.GetContent(TempBlob);
                    //TempBlob.CreateInStream(InStream, EncodingType::MSDos);
                    //  TempBlob.CreateInStream(InStream);
                    // Re-create TempBlob InStream (fresh) and pass the TempBlob (not the consumed InStream)
                    //TempBlob.CreateInStream(SourceInStream);
                    if IncomingDocumentAttachment."Main Attachment" then
                        FileName := IncomingDoc.GetMainAttachmentFileName()
                    else
                        FileName := IncomingDocumentAttachment.GetFullName();
                    //                    MESSAGE('%1', SourceInStream.Length()); // [THEN] 


                    InsertAttachment(SourceInStream, RecRef, FileName, true);
                    if IncomingDoc.Posted and (IncomingDoc."Document No." <> '') then begin
                        PostedRecRef := DetectPostedDocumentAsRecordRef(IncomingDoc."Document No.", IncomingDoc."Posting Date");
                        if Not PostedRecRef.IsEmpty then
                            InsertAttachment(PostedInStream, PostedRecRef, FileName, true);
                    end;

                    if DeleteAfterMove then
                        IncomingDocumentAttachment.Delete(false);
                    //end;
                end;
            Until IncomingDocumentAttachment.Next() = 0;
        if DeleteAfterMove then
            IncomingDoc.Delete(false);
    END;

    local procedure DetectPostedDocumentAsRecordRef(DocNo: Code[50]; PostDate: Date): RecordRef
    var
        RecRef: RecordRef;
        SalesInvHeader: Record "Sales Invoice Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        ReturnShipmentHeader: Record "Return Shipment Header";
        ServiceInvHeader: Record "Service Invoice Header";
        ServiceShipmentHdr: Record "Service Shipment Header";
        ServiceCrMemoHdr: Record "Service Cr.Memo Header";
    begin
        // --- SALES ---
        if SalesInvHeader.Get(DocNo) and (SalesInvHeader."Posting Date" = PostDate) then begin
            RecRef.Open(Database::"Sales Invoice Header");
            RecRef.Get(SalesInvHeader.RecordId);
            exit(RecRef);
        end;

        if SalesShipmentHeader.Get(DocNo) and (SalesShipmentHeader."Posting Date" = PostDate) then begin
            RecRef.Open(Database::"Sales Shipment Header");
            RecRef.Get(SalesShipmentHeader.RecordId);
            exit(RecRef);
        end;

        if SalesCrMemoHeader.Get(DocNo) and (SalesCrMemoHeader."Posting Date" = PostDate) then begin
            RecRef.Open(Database::"Sales Cr.Memo Header");
            RecRef.Get(SalesCrMemoHeader.RecordId);
            exit(RecRef);
        end;

        if ReturnReceiptHeader.Get(DocNo) and (ReturnReceiptHeader."Posting Date" = PostDate) then begin
            RecRef.Open(Database::"Return Receipt Header");
            RecRef.Get(ReturnReceiptHeader.RecordId);
            exit(RecRef);
        end;

        // --- PURCHASE ---
        if PurchInvHeader.Get(DocNo) and (PurchInvHeader."Posting Date" = PostDate) then begin
            RecRef.Open(Database::"Purch. Inv. Header");
            RecRef.Get(PurchInvHeader.RecordId);
            exit(RecRef);
        end;

        if PurchRcptHeader.Get(DocNo) and (PurchRcptHeader."Posting Date" = PostDate) then begin
            RecRef.Open(Database::"Purch. Rcpt. Header");
            RecRef.Get(PurchRcptHeader.RecordId);
            exit(RecRef);
        end;

        if PurchCrMemoHdr.Get(DocNo) and (PurchCrMemoHdr."Posting Date" = PostDate) then begin
            RecRef.Open(Database::"Purch. Cr. Memo Hdr.");
            RecRef.Get(PurchCrMemoHdr.RecordId);
            exit(RecRef);
        end;

        if ReturnShipmentHeader.Get(DocNo) and (ReturnShipmentHeader."Posting Date" = PostDate) then begin
            RecRef.Open(Database::"Return Shipment Header");
            RecRef.Get(ReturnShipmentHeader.RecordId);
            exit(RecRef);
        end;

        // --- SERVICE ---
        if ServiceInvHeader.Get(DocNo) and (ServiceInvHeader."Posting Date" = PostDate) then begin
            RecRef.Open(Database::"Service Invoice Header");
            RecRef.Get(ServiceInvHeader.RecordId);
            exit(RecRef);
        end;

        if ServiceShipmentHdr.Get(DocNo) and (ServiceShipmentHdr."Posting Date" = PostDate) then begin
            RecRef.Open(Database::"Service Shipment Header");
            RecRef.Get(ServiceShipmentHdr.RecordId);
            exit(RecRef);
        end;

        if ServiceCrMemoHdr.Get(DocNo) and (ServiceCrMemoHdr."Posting Date" = PostDate) then begin
            RecRef.Open(Database::"Service Cr.Memo Header");
            RecRef.Get(ServiceCrMemoHdr.RecordId);
            exit(RecRef);
        end;

        // Not found -> return empty RecordRef
        exit(RecRef);
    end;

    local procedure InsertPostedAttachment(var ImportStream: InStream; RecRef: RecordRef; FileName: Text; AllowDuplicateFileName: Boolean)
    var
        IsHandled: Boolean;
        DocAttachment: Record "Document Attachment";
        FileManagement: Codeunit "File Management";
        CopyInvAttachToOrder: Codeunit "Copy Inv Attch To Order";
        CopyPurchInvAttachToOrder: Codeunit "Copy Purch Inv Attch To Order";
        isSalesInvDoc: Boolean;
        isPurchinvDoc: Boolean;
        IncomingFileName: Text;
    begin
        if not RecRef.Find() then
            exit;

        if AllowDuplicateFileName then
            IncomingFileName := DocAttachment.FindUniqueFileName(FileManagement.GetFileNameWithoutExtension(FileName), FileManagement.GetExtension(FileName))
        else
            IncomingFileName := FileName;

        DocAttachment.SaveAttachmentFromStream(ImportStream, RecRef, IncomingFileName);
    end;


    local procedure InsertAttachment(var ImportStream: InStream; RecRef: RecordRef; FileName: Text; AllowDuplicateFileName: Boolean)
    var
        IsHandled: Boolean;
        DocAttachment: Record "Document Attachment";
        FileManagement: Codeunit "File Management";
        CopyInvAttachToOrder: Codeunit "Copy Inv Attch To Order";
        CopyPurchInvAttachToOrder: Codeunit "Copy Purch Inv Attch To Order";
        isSalesInvDoc: Boolean;
        isPurchinvDoc: Boolean;
        IncomingFileName: Text;
    begin
        if not RecRef.Find() then
            exit;

        if RecRef.Number = Database::"Sales Invoice Header" then begin
            isSalesInvDoc := true;
            RecRef.SetTable(SalesInvHeader);
        end;

        if RecRef.Number = Database::"Purch. Inv. Header" then begin
            isPurchinvDoc := true;
            RecRef.SetTable(PurchInvHeader);
        end;
        if AllowDuplicateFileName then
            IncomingFileName := DocAttachment.FindUniqueFileName(FileManagement.GetFileNameWithoutExtension(FileName), FileManagement.GetExtension(FileName))
        else
            IncomingFileName := FileName;

        DocAttachment.SaveAttachmentFromStream(ImportStream, RecRef, IncomingFileName);
        //DocAttachment.InitFieldsFromRecRef(RecRef);

        // Determine unique file name if required

        //DocAttachment.Validate("File Extension", FileManagement.GetExtension(IncomingFileName));
        //DocAttachment.Validate("File Name", CopyStr(FileManagement.GetFileNameWithoutExtension(IncomingFileName), 1, MaxStrLen(DocAttachment."File Name")));

        // Create a fresh InStream from the TempBlob to ensure stream is at start
        //TempBlob.CreateInStream(ImportStream);

        //  if not IsHandled then begin
        // ImportFromStream consumes the stream; using a fresh stream avoids EOF issues
        //    DocAttachment.ImportFromStream(ImportStream, IncomingFileName);

        // Verify import actually wrote content
        //  if not DocAttachment.HasContent() then
        //    if Not DocAttachment."Attachment Blob".HasValue then
        //      Error(NoDocumentAttachedErr);
        //end;

        // Optional hook before inserting
        //  OnBeforeImportWithFilter(DocAttachment, RecRef);

        // Persist the attachment record
        // DocAttachment.Insert(true);

        // If relevant, copy attachment to related open order (existing logic)
        if isSalesInvDoc then
            CopyInvAttachToOrder.CopyFromPostedInvoiceToOpenOrder(SalesInvHeader."No.");

        if isPurchinvDoc then
            CopyPurchInvAttachToOrder.CopyFromPostedInvoiceToOpenOrder(PurchInvHeader."No.");
    end;

    procedure CopyAttachments(var FromRecRef: RecordRef; var ToRecRef: RecordRef)
    var
        FromDocumentAttachment: Record "Document Attachment";
        ToDocumentAttachment: Record "Document Attachment";
        ToDocumentAttachment2: Record "Document Attachment";
        FromFieldRef: FieldRef;
        ToFieldRef: FieldRef;
        FromAttachmentDocumentType: Enum "Attachment Document Type";
        FromLineNo: Integer;
        FromNo: Code[20];
        ToNo: Code[20];
        ToAttachmentDocumentType: Enum "Attachment Document Type";
        ToLineNo: Integer;
        IsHandled: Boolean;
    begin
        FromDocumentAttachment.SetRange("Table ID", FromRecRef.Number);
        if FromDocumentAttachment.IsEmpty() then
            exit;

        case FromRecRef.Number() of
            Database::"Sales Invoice Header",
            Database::"Purch. Inv. Header":
                begin
                    FromFieldRef := FromRecRef.Field(3);
                    FromNo := FromFieldRef.Value();
                    FromDocumentAttachment.SetRange("No.", FromNo);
                end;
        end;


        if FromDocumentAttachment.FindSet() then begin
            case ToRecRef.Number() of
                Database::"Sales Header",
                Database::"Purchase Header":
                    begin
                        ToFieldRef := ToRecRef.Field(1);
                        ToAttachmentDocumentType := ToFieldRef.Value();

                        ToFieldRef := ToRecRef.Field(3);
                        ToNo := ToFieldRef.Value();
                    end;
            end;
            repeat
                Clear(ToDocumentAttachment);
                ToDocumentAttachment.Init();
                ToDocumentAttachment.TransferFields(FromDocumentAttachment);

                ToDocumentAttachment.Validate("Table ID", ToRecRef.Number);
                ToDocumentAttachment.Validate("No.", ToNo);
                case ToRecRef.Number() of
                    Database::"Sales Header",
                    Database::"Purchase Header":
                        ToDocumentAttachment.Validate("Document Type", ToAttachmentDocumentType);
                end;

                if not ToDocumentAttachment.Insert(true) then begin
                    ToDocumentAttachment2 := ToDocumentAttachment;
                    ToDocumentAttachment.Find('=');
                    ToDocumentAttachment.TransferFields(ToDocumentAttachment2, false);
                end;

                ToDocumentAttachment."Attached Date" := FromDocumentAttachment."Attached Date";
                ToDocumentAttachment.Modify();

            until FromDocumentAttachment.Next() = 0;
        end;

        // Copies attachments for header and then calls CopyAttachmentsForPostedDocsLines to copy attachments for lines.
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
        SalesInvHeader: Record "Sales Invoice Header";
        PurchInvHeader: Record "Purch. Inv. Header";


}
