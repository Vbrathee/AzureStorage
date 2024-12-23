pageextension 88100 "PDFV2 Document Attachment Det" extends "Document Attachment Details" //1173
{
    actions
    {
        addlast(processing)
        {
            action("PDFV2 View PDF")
            {
                ApplicationArea = All;
                Image = Text;
                Caption = 'View PDF';
                ToolTip = 'View PDF';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Enabled = Rec."File Extension" = 'pdf';
                trigger OnAction()
                var
                    ABSBlobClient: codeunit "ABS Blob Client";
                    Authorization: Interface "Storage Service Authorization";
                    ABSContainersetup: Record "ABS Container setup";
                    StorageServiceAuthorization: Codeunit "Storage Service Authorization";
                    TempBlob: Codeunit "Temp Blob";
                    PDFViewer: Page "PDFV2 PDF Viewer";
                    PDFOutStream: OutStream;
                    PDFInStream: InStream;
                    Filename: Text;
                begin
                    // TempBlob.CreateOutStream(PDFOutStream, TextEncoding::UTF8);
                    ABSContainersetup.Get;
                    Authorization := StorageServiceAuthorization.CreateSharedKey(ABSContainersetup."Shared Access Key");
                    ABSBlobClient.Initialize(ABSContainersetup."Account Name", ABSContainersetup."Container Name", Authorization);
                    Filename := Rec."File Name" + '.' + Rec."File Extension";
                    // ABSBlobClient.GetBlobAsFile(Filename);
                    // ABSBlobClient.PutBlobBlockBlobStream(FileName, PDFInStream);
                    ABSBlobClient.GetBlobAsStream(Filename, PDFInStream);
                    // TempBlob.CreateOutStream(PDFOutStream, TextEncoding::UTF8);
                    // Rec."Document Reference ID".ExportStream(PDFOutStream);
                    // TempBlob.CreateInStream(PDFInStream, TextEncoding::UTF8);
                    PDFViewer.SetPDFDocument(PDFInStream);
                    PDFViewer.Run();
                end;
            }
        }
    }
}
