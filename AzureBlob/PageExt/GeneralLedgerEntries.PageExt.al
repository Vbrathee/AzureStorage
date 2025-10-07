pageextension 88003 GeneralLedgerEntriesExt extends "General Ledger Entries"
{
    layout
    {
        // Add changes to page layout here

    }


    actions
    {
        addlast(processing)
        {
            action(ShowDocumentAttachment)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Show Document Attachment';
                Enabled = HasDocumentAttachment;
                Image = Attach;
                ToolTip = 'View documents or images that are attached to the posted invoice or credit memo.';

                trigger OnAction()
                var
                    CustLedgerEntry: Record "Cust. Ledger Entry";
                    VendLedgEntry: Record "Vendor Ledger Entry";
                begin
                    CustLedgerEntry.Setrange("Transaction No.", Rec."Transaction No.");
                    if CustLedgerEntry.findfirst then begin
                        CustLedgerEntry.ShowPostedDocAttachment();
                    end else begin
                        VendLedgEntry.SetRange("Transaction No.", Rec."Transaction No.");
                        if VendLedgEntry.FindFirst() then begin
                            VendLedgEntry.ShowPostedDocAttachment();
                        End;
                    End;
                End;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        HasDocumentAttachment := false;
        CustLedgerEntry.Setrange("Transaction No.", Rec."Transaction No.");
        if CustLedgerEntry.findfirst then begin
            HasDocumentAttachment := CustLedgerEntry.HasPostedDocAttachment();
        end else begin
            VendLedgEntry.SetRange("Transaction No.", Rec."Transaction No.");
            if VendLedgEntry.FindFirst() then begin
                HasDocumentAttachment := VendLedgEntry.HasPostedDocAttachment();
            end;
        end;
    end;

    var
        HasDocumentAttachment: Boolean;
}