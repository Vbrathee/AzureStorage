tableextension 88000 "Document Attachment" extends "Document Attachment"
{
    fields
    {
        field(88000; "Delete Azure BLOB"; Boolean)
        {
            Caption = 'Delete Azure BLOB';
            DataClassification = ToBeClassified;
        }
        field(88001; "Folder Name"; Text[1024])
        {
            Caption = 'Folder Name';
            DataClassification = ToBeClassified;
        }
        field(88002; "Moved Attachment"; Boolean)
        {
            Caption = 'Moved Attachment';
            DataClassification = ToBeClassified;
        }
        field(88003; "Attachment Blob"; Blob)
        {
            Caption = 'Attachment Blob';
            //SubType = ;
            SubType = Bitmap;
            DataClassification = ToBeClassified;
        }
        field(88004; "Processed"; Boolean)
        {
            Caption = 'Processes';
            DataClassification = ToBeClassified;
        }
        field(88005; "Journal Template Name"; Code[10])
        {
            //Caption = 'Processes';
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Template";
        }
        field(88006; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Journal Template Name"));
        }
        field(88007; "Ledger Entry No."; Integer)
        {
            Caption = 'Ledger Entry No.';
            DataClassification = ToBeClassified;
        }
    }

    procedure InsertAttachmentGL(DocStream: InStream; RecRef: RecordRef; FileName: Text; AllowDuplicateFileName: Boolean)
    var
        IsHandled: Boolean;
    begin
        InitFieldsFromRecRef(RecRef);

        // If duplicate filename is allowed, use increment versions (specifically needed for phone Take/Use Photo functionality)
        if AllowDuplicateFileName then
            IncomingFileName := FindUniqueFileName(FileManagement.GetFileNameWithoutExtension(FileName), FileManagement.GetExtension(FileName))
        else
            IncomingFileName := FileName;

        Validate("File Extension", FileManagement.GetExtension(IncomingFileName));
        Validate("File Name", CopyStr(FileManagement.GetFileNameWithoutExtension(IncomingFileName), 1, MaxStrLen("File Name")));

        //OnInsertAttachmentOnBeforeImportStream(Rec, DocStream, FileName, IsHandled);
        if not IsHandled then begin
            // IMPORTSTREAM(stream,description, mime-type,filename)
            // description and mime-type are set empty and will be automatically set by platform code from the filename
            ImportFromStream(DocStream, FileName);
            if not HasContent() then
                Error(NoDocumentAttachedErr);
        end;

        OnBeforeInsertAttachmentGL(Rec, RecRef);
        Insert(true);
    end;


    trigger OnInsert()
    begin
        "Delete Azure BLOB" := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertAttachmentGL(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    begin
    end;

    var
        FileManagement: Codeunit "File Management";
        IncomingFileName: Text;
        NoDocumentAttachedErr: Label 'Please attach a document first.';
        EmptyFileNameErr: Label 'Please choose a file to attach.';
        NoContentErr: Label 'The selected file ''%1'' has no content. Please choose another file.', Comment = '%1=FileName';
        DuplicateErr: Label 'This file is already attached to the document. Please choose another file.';
        RecordRefNotFoundErr: Label 'The record reference is empty. Please save the record before attaching files.';


}
