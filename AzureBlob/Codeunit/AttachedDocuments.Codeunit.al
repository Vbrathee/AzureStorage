codeunit 88000 AttachedDocuments
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::table, 1173, 'OnBeforeInsertAttachment', '', true, true)]
    local procedure OnBeforeImportWithFilter(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
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
            DocumentAttachment."Folder Name" := GetFolderName(DocumentAttachment."Table ID", DocumentAttachment."Document Type", DocumentAttachment);
            OldFileName := DocumentAttachment."File Name";
            DocumentAttachment."File Name" := GetFileName(DocumentAttachment."Table ID", DocumentAttachment."Document Type", DocumentAttachment, DocumentAttachment."File Name");
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Attachment Mgmt", OnAfterTableIsDocument, '', true, true)]
    local procedure OnAfterTableIsDocument(TableNo: Integer; var IsDocument: Boolean);
    begin
        IsDocument := TableNo in
                        [Database::"Transfer Header",
                        Database::"Transfer Receipt Header",
                        Database::"Transfer Shipment Header"];

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Attachment Mgmt", OnAfterTableHasNumberFieldPrimaryKey, '', true, true)]
    local procedure OnAfterTableHasNumberFieldPrimaryKey(TableNo: Integer; var Result: Boolean; var FieldNo: Integer)
    begin
        case TableNo of
            Database::"Transfer Header",
            Database::"Transfer Receipt Header",
            Database::"Transfer Shipment Header":
                begin
                    FieldNo := 1;
                    Result := true;
                end;
        End;
    end;

    [EventSubscriber(ObjectType::table, 1173, OnBeforeDeleteEvent, '', true, true)]
    local procedure DeleteDocumentAttachment(var Rec: Record "Document Attachment"; RunTrigger: Boolean)

    var
        ABSBlobClient: codeunit "ABS Blob Client";
        Authorization: Interface "Storage Service Authorization";
        ABSContainersetup: Record "ABS Container Acc setup";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        Filename: Text;
        ContainerName: Text;
        Substrting: Text;
    begin
        ABSContainersetup.Get();
        if ABSContainersetup."Enable Container Setup" then begin
            if not Rec."Delete Azure BLOB" then
                exit;
            //            else
            //              if not Confirm('Do you want to delete the file from azure blob?') then
            //                exit;
            If RunTrigger then begin
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

                ABSBlobClient.DeleteBlob(Filename);
            end;
        End;
    end;

    /*     procedure GetContainerName(TableID: Integer; DocumentType: Enum "Attachment Document Type"): Text
        var
            ContainerNameSetup: Record "ABS Container Name setup";
            ABSContAccSetup: Record "ABS Container Acc setup";

        begin
            ABSContAccSetup.Get();
            if ABSContAccSetup."Enable Multiple Cont. Setup" then begin
                ContainerNameSetup.SetRange("Table ID", TableID);
                ContainerNameSetup.SetRange("Document Type", DocumentType);
                if ContainerNameSetup.FindFirst() then begin
                    ContainerNameSetup.TestField("Container Name");
                    Exit(ContainerNameSetup."Container Name");
                end else
                    Error('Please define container Name for Table ID %1 and Document Type %2', TableID, DocumentType);
            end else begin
                ABSContAccSetup.TestField("Container Name");
                Exit(ABSContAccSetup."Container Name");
            end;
        end;
     */
    [EventSubscriber(ObjectType::table, 1173, 'OnAfterInsertEvent', '', true, true)]
    local procedure DeleteMediaField(var Rec: Record "Document Attachment"; RunTrigger: Boolean)
    var
        ABSContainersetup: Record "ABS Container Acc setup";
    begin
        ABSContainersetup.Get();
        if ABSContainersetup."Enable Container Setup" then begin
            If RunTrigger then begin
                Clear(Rec."Document Reference ID");
                rec.Modify();
            end;
        End;
    end;

    [EventSubscriber(ObjectType::Table, database::"Document Attachment", OnInsertOnBeforeCheckDocRefID, '', false, false)]
    local procedure OnInsertOnBeforeCheckDocRefID(var DocumentAttachment: Record "Document Attachment"; var IsHandled: Boolean)
    Var
        ABSContainersetup: Record "ABS Container Acc setup";
    begin
        ABSContainersetup.Get();
        if ABSContainersetup."Enable Container Setup" then begin
            DocumentAttachment."File Name" := GetFileName(DocumentAttachment."Table ID", DocumentAttachment."Document Type", DocumentAttachment, DocumentAttachment."File Name");
            DocumentAttachment."Folder Name" := GetFolderName(DocumentAttachment."Table ID", DocumentAttachment."Document Type", DocumentAttachment);

            IsHandled := true;

        End;
    end;

    procedure GetFolderName(TableID: Integer; DocumentType: Enum "Attachment Document Type"; DocumentAttachment: Record "Document Attachment"): Text
    var
        AbsFolderSequence: Record "ABS Folder Sequence setup";
        ABSFolderSetup: Record "ABS Folder setup";
        ContainerSetup: Record "ABS Container Acc setup";
        FolderName: Text;
        CompanyInformation: Record "Company Information";
    begin
        ContainerSetup.Get();
        if ContainerSetup."Enable Folder Setup" then begin
            ABSFolderSetup.SetRange("Table ID", TableID);
            if TableID in [36, 38] then
                ABSFolderSetup.SetRange("Document Type", DocumentType);
            if ABSFolderSetup.findfirst then begin
                if ABSFolderSetup."Enable Folder Sequence" then begin
                    AbsFolderSequence.SetRange("Table ID", TableID);
                    //if TableID in [36, 38] then
                    AbsFolderSequence.SetRange("Document Type", ABSFolderSetup."Document Type");
                    AbsFolderSequence.SetRange(Type, Enum::"ABS Type"::"Folder Name");
                    if AbsFolderSequence.Findset then begin
                        repeat
                            case AbsFolderSequence."Sequence Type" of
                                Enum::"ABS Sequence Type"::"Company Name":
                                    begin
                                        CompanyInformation.Get();
                                        UpdateFolderName(FolderName, CompanyInformation.Name);
                                    end;
                                Enum::"ABS Sequence Type"::Day:
                                    begin
                                        UpdateFolderName(FolderName, FORMAT(DATE2DMY(WorkDate(), 1)));
                                    End;
                                Enum::"ABS Sequence Type"::Month:
                                    begin
                                        UpdateFolderName(FolderName, FORMAT(DATE2DMY(WorkDate(), 2)));
                                    End;
                                Enum::"ABS Sequence Type"::Year:
                                    begin
                                        UpdateFolderName(FolderName, FORMAT(DATE2DMY(WorkDate(), 3)));
                                    End;
                                Enum::"ABS Sequence Type"::"Posting Date":
                                    begin
                                        UpdateFolderName(FolderName, Format(WorkDate(), 0, '<Day,2>.<Month,2>.<Year4>'));
                                    End;
                                Enum::"ABS Sequence Type"::Manual:
                                    begin
                                        UpdateFolderName(FolderName, AbsFolderSequence."Folder Name");
                                    End;
                                Enum::"ABS Sequence Type"::"Field Ref":
                                    begin
                                        UpdateFolderNameFieldRef(FolderName, AbsFolderSequence."Field ID", DocumentAttachment);
                                    End;

                            End;

                        Until AbsFolderSequence.Next() = 0;
                        exit(FolderName);
                    end else
                        error('Please define folder sequance');
                end else
                    if ABSFolderSetup."Folder Name" <> '' then BEGIN
                        Exit(ABSFolderSetup."Folder Name");
                    END else
                        exit('');
            end else begin
                ABSFolderSetup.SetRange("Document Type");
            end;
        end else
            EXIT('');
    end;

    procedure GetFileName(TableID: Integer; DocumentType: Enum "Attachment Document Type"; DocumentAttachment: Record "Document Attachment"; FileName: Text): Text
    var
        AbsFolderSequence: Record "ABS Folder Sequence setup";
        ABSFolderSetup: Record "ABS Folder setup";
        ContainerSetup: Record "ABS Container Acc setup";
        FolderName: Text;
        CompanyInformation: Record "Company Information";
    begin
        ContainerSetup.Get();
        if ContainerSetup."Enable Folder Setup" then begin
            ABSFolderSetup.SetRange("Table ID", TableID);
            ABSFolderSetup.SetRange("Document Type", DocumentType);
            if ABSFolderSetup.findfirst then begin
                if ABSFolderSetup."Enable Folder Sequence" then begin
                    AbsFolderSequence.SetRange("Table ID", TableID);
                    AbsFolderSequence.SetRange("Document Type", DocumentType);
                    AbsFolderSequence.SetRange(Type, Enum::"ABS Type"::"File Name");
                    if AbsFolderSequence.FindFirst() then begin

                        case AbsFolderSequence."Sequence Type" of
                            Enum::"ABS Sequence Type"::"Company Name":
                                begin
                                    CompanyInformation.Get();
                                    UpdateFileName(FolderName, CompanyInformation.Name);
                                end;
                            Enum::"ABS Sequence Type"::Day:
                                begin
                                    UpdateFileName(FolderName, FORMAT(DATE2DMY(WorkDate(), 1)));
                                End;
                            Enum::"ABS Sequence Type"::Month:
                                begin
                                    UpdateFileName(FolderName, FORMAT(DATE2DMY(WorkDate(), 2)));
                                End;
                            Enum::"ABS Sequence Type"::Year:
                                begin
                                    UpdateFileName(FolderName, FORMAT(DATE2DMY(WorkDate(), 3)));
                                End;
                            Enum::"ABS Sequence Type"::"Posting Date":
                                begin
                                    UpdateFileName(FolderName, Format(WorkDate(), 0, '<Day,2>.<Month,2>.<Year4>'));
                                End;
                            Enum::"ABS Sequence Type"::Manual:
                                begin
                                    UpdateFileName(FolderName, AbsFolderSequence."Folder Name");
                                End;
                            Enum::"ABS Sequence Type"::"Field Ref":
                                begin
                                    UpdateFolderNameFieldRef(FolderName, AbsFolderSequence."Field ID", DocumentAttachment);
                                End;

                        End;
                        exit(FolderName);
                    end else
                        exit(FileName);
                end;
            end;
            //    EXIT('');
        end;
        exit(FileName);
    End;


    local procedure UpdateFolderName(Var OldFolderText: Text; NewFolderName: Text)
    begin
        NewFolderName := NewFolderName.Replace('/', '_');
        if OldFolderText <> '' then begin
            if NewFolderName <> '' then
                OldFolderText := OldFolderText + '/' + NewFolderName;
        end else
            if NewFolderName <> '' then
                OldFolderText := NewFolderName;
    end;

    local procedure UpdateFileName(Var OldFileText: Text; NewFileName: Text)
    begin
        NewFileName := NewFileName.Replace('/', '_');
        if OldFileText <> '' then begin
            if NewFileName <> '' then
                OldFileText := OldFileText + NewFileName;
        end else
            if NewFileName <> '' then
                OldFileText := NewFileName;
    end;

    local procedure UpdateFolderNameFieldRef(Var OldFolderText: Text; FieldID: Integer; DocumentAttachment: Record "Document Attachment")
    Var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        RecNo: Code[20];
        AttachmentDocumentType: Enum "Attachment Document Type";
        FieldNo: Integer;
        LineNo: Integer;
        VATRepConfigType: Enum "VAT Report Configuration";
        FieldValue: Text;

    begin
        //RecRef.SetTable(DocumentAttachment."Table ID");
        recRef.Open(DocumentAttachment."Table ID");
        if TableHasNumberFieldPrimayKey(DocumentAttachment."Table ID", FieldNo) then begin
            FieldRef := RecRef.Field(FieldNo);
            FieldRef.SetFilter(DocumentAttachment."No.");
            //RecNo := FieldRef.Value();

        end;

        if TableHasBatchNamePrimaryKey(DocumentAttachment."Table ID", FieldNo) then begin
            FieldRef := RecRef.Field(FieldNo);
            FieldRef.SetRange(DocumentAttachment."Line No.");
            //RecNo := FieldRef.Value();

        end;


        if TableHasDocTypePrimaryKey(DocumentAttachment."Table ID", FieldNo) then begin
            FieldRef := RecRef.Field(FieldNo);
            FieldRef.SetRange(DocumentAttachment."Document Type");

        end;

        if TableHasLineNumberPrimaryKey(DocumentAttachment."Table ID", FieldNo) then begin
            FieldRef := RecRef.Field(FieldNo);
            FieldRef.SetRange(DocumentAttachment."Line No.");
        end;

        if TableHasVATReportConfigCodePrimaryKey(DocumentAttachment."Table ID", FieldNo) then begin
            FieldRef := RecRef.Field(FieldNo);
            FieldRef.Setrange(DocumentAttachment."VAT Report Config. Code");

        end;
        if RecRef.Findfirst() then begin
            FieldRef := RecRef.Field(FieldID);
            FieldValue := FieldRef.Value();
            FieldValue := FieldValue.Replace('/', '_');
            if OldFolderText <> '' then begin
                if FieldValue <> '' then
                    OldFolderText := OldFolderText + '/' + FieldValue;
            end else
                OldFolderText := FieldValue;
        end;
    end;




    procedure TableHasNumberFieldPrimayKey(TableNo: Integer; var FieldNo: Integer): Boolean
    var
        Result: Boolean;
    begin
        case TableNo of
            Database::Customer,
            Database::Vendor,
            Database::Item,
            Database::Employee,
            Database::"Fixed Asset",
            Database::Job,
            Database::Resource,
            Database::"VAT Report Header",
            Database::Opportunity,
            Database::"Transfer Header",
            Database::"Transfer Receipt Header",
            Database::"Transfer Shipment Header",
            Database::"Gen. Journal Line",
            Database::"Item Journal Line":
                begin
                    FieldNo := 1;
                    exit(true);
                end;
            Database::"Sales Header",
            Database::"Sales Line",
            Database::"Purchase Header",
            Database::"Purchase Line",
            Database::"Sales Invoice Header",
            Database::"Sales Cr.Memo Header",
            Database::"Purch. Inv. Header",
            Database::"Purch. Cr. Memo Hdr.",
            Database::"Sales Invoice Line",
            Database::"Sales Cr.Memo Line",
            Database::"Purch. Inv. Line",
            Database::"Purch. Cr. Memo Line",
            Database::"Service Header",
            Database::"Service Shipment Header",
            Database::"Service Invoice Header":
                begin
                    FieldNo := 3;
                    exit(true);
                end;
        end;
        Result := false;
        exit(Result);
    end;

    procedure TableHasDocTypePrimaryKey(TableNo: Integer; var FieldNo: Integer): Boolean
    var
        Result: Boolean;
    begin
        case TableNo of
            Database::"Sales Header",
            Database::"Sales Line",
            Database::"Purchase Header",
            Database::"Purchase Line",
            Database::"Service Header":
                begin
                    FieldNo := 1;
                    exit(true);
                end;
        end;

        Result := false;
        exit(Result);
    end;

    procedure TableHasBatchNamePrimaryKey(TableNo: Integer; var FieldNo: Integer): Boolean
    var
        Result: Boolean;
    begin
        case TableNo of
            Database::"Gen. Journal Line":
                begin
                    FieldNo := 51;
                    exit(true);
                end;
            Database::"Item Journal Line":
                begin
                    FieldNo := 41;
                    exit(true);
                end;

        end;

        Result := false;
        exit(Result);
    end;

    procedure TableHasLineNumberPrimaryKey(TableNo: Integer; var FieldNo: Integer): Boolean
    var
        Result: Boolean;
    begin
        case TableNo of
            Database::"Sales Line",
            Database::"Purchase Line",
            Database::"Sales Invoice Line",
            Database::"Sales Cr.Memo Line",
            Database::"Purch. Inv. Line",
            Database::"Purch. Cr. Memo Line":
                begin
                    FieldNo := 4;
                    exit(true);
                end;
            Database::"Gen. Journal Line",
            Database::"Item Journal Line":
                begin
                    FieldNo := 2;
                    exit(true);
                end;
        end;

        Result := false;
        exit(Result);
    end;

    procedure TableHasVATReportConfigCodePrimaryKey(TableNo: Integer; var FieldNo: Integer): Boolean
    begin
        if TableNo in
            [Database::"VAT Report Header"]
        then begin
            FieldNo := 2;
            exit(true);
        end;

        exit(false);
    end;

    /*      procedure MoveAndDeleteIncomingMediaToDocumentAttachment(IncomingDocFileID: Code[20]; TargetTableID: Integer; TargetRecordID: Code[20])
        var
            IncomingDocFile: Record "Incoming Document";
            DocAttachment: Record "Document Attachment";
            InStream: InStream;
            TempBlob: Codeunit "Temp Blob";
        begin
            // 1. Get the Incoming Document File
            if IncomingDocFile.Get(IncomingDocFileID) then begin

                // 2. Ensure media exists
                IncomingDocFile.CalcFields("File Content");
                if IncomingDocFile."File Content".HasValue then begin

                    // 3. Read media stream
                    IncomingDocFile."File Content".CreateInStream(InStream);

                    // 4. Create Document Attachment
                    DocAttachment.Init();
                    DocAttachment."Table ID" := TargetTableID;
                    DocAttachment."No." := TargetRecordID;
                    DocAttachment."Document Type" := DocAttachment."Document Type"::;
                    DocAttachment."File Name" := IncomingDocFile."File Name";
                    DocAttachment."File Extension" := IncomingDocFile."File Extension";
                    DocAttachment."Attachment Date" := Today;
                    DocAttachment."User ID" := UserId;
                    DocAttachment."Attachment".ImportStream(InStream, IncomingDocFile."File Name");
                    DocAttachment.Insert();

                    // 5. Delete media content from Incoming Document File
                    IncomingDocFile."File Content".Clear();
                    IncomingDocFile.Modify(true);

                    // Optional: delete the entire IncomingDocFile record
                    // IncomingDocFile.Delete();
                end;
            end;
        end;
      */



}