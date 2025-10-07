pageextension 88002 IncomingDocumentExt extends "Incoming Document"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addlast(processing)
        {
            action(MovetoDocumentAttachment)
            {
                ApplicationArea = All;
                Caption = 'Move to Document Attachment';
                Image = CreateMovement;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;
                ToolTip = 'Move file from incoming document to document attachment';

                trigger OnAction()
                var
                    IncomingDocMov: Codeunit "Incoming Doc To DocAttach";
                    CustLedgEntry: Page "Customer Ledger Entries";
                    SalesOrder: Page "Sales Order";
                    SalesOrderSubform: Page "Sales Order Subform";
                begin
                    IncomingDocMov.MoveSingleIncomingDocsToAttachments(Rec, true);

                end;
            }
        }
    }

    var
        myInt: Integer;
}