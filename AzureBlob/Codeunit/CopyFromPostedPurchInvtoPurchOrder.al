codeunit 88008 "Copy Purch Inv Attch To Order"
{
    Subtype = Normal;
    SingleInstance = false;

    procedure CopyFromPostedInvoiceToOpenOrder(SalesInvNo: Code[20])
    var
        SalesInvHdr: Record "Purch. Inv. Header";
        SalesInvLine: Record "Purch. Inv. Line";
        SalesHdr: Record "Purchase Header";
        SalesLine: Record "Purchase Line";
        ShipLine: Record "Purch. Rcpt. Line";
        SalesShipHeader: Record "Purch. Rcpt. Header";
        DocAttachMgt: Codeunit "Document Attachment Mgmt";
        FromRef: RecordRef;
        ToRef: RecordRef;
        TargetOrderNo: Code[20];
        TargetOrderFound: Boolean;
        HandledLines: Dictionary of [Integer, Integer]; // key: Inv Line No. -> value: Order Line No.
    begin
        if not SalesInvHdr.Get(SalesInvNo) then
            exit;

        // 1) Identify target OPEN sales order
        TargetOrderNo := '';
        TargetOrderFound := false;

        // Preferred route: direct Order No. on the invoice header
        if SalesInvHdr."Order No." <> '' then begin
            if SalesHdr.Get(SalesHdr."Document Type"::Order, SalesInvHdr."Order No.") then
                if SalesHdr.Status = SalesHdr.Status::Open then begin
                    TargetOrderNo := SalesHdr."No.";
                    TargetOrderFound := true;
                end;
        end;

        // Fallback route: resolve via shipment lines on the invoice lines
        if not TargetOrderFound then begin
            SalesInvLine.Reset();
            SalesInvLine.SetRange("Document No.", SalesInvHdr."No.");
            if SalesInvLine.FindSet() then
                repeat
                    if (SalesInvLine."Receipt No." <> '') and (SalesInvLine."Receipt Line No." <> 0) then begin
                        ShipLine.Reset();
                        ShipLine.SetRange("Document No.", SalesInvLine."Receipt No.");
                        ShipLine.SetRange("Line No.", SalesInvLine."Receipt Line No.");
                        if ShipLine.FindFirst() then begin
                            if SalesShipHeader.Get(ShipLine."Document No.") then begin
                                if (SalesShipHeader."Order No." <> '') and
                                   SalesHdr.Get(SalesHdr."Document Type"::Order, SalesShipHeader."Order No.")
                                then begin
                                    TargetOrderNo := SalesHdr."No.";
                                    TargetOrderFound := true;
                                    // no need to keep searching once we have an open order
                                    //CopyFromPostedInvoiceToSpecificOrder(SalesInvHdr, TargetOrderNo);
                                end;
                            end;
                        end;
                    end;
                until (SalesInvLine.Next() = 0) or TargetOrderFound;
        end;

        if not TargetOrderFound then
            exit;
        if SalesHdr.Get(SalesHdr."Document Type"::Order, TargetOrderNo) then
            CopyFromPostedInvoiceToSpecificOrder(SalesInvHdr, SalesHdr);
    end;

    local procedure CopyFromPostedInvoiceToSpecificOrder(var SalesInvHdr: Record "Purch. Inv. Header"; SalesHdr: Record "Purchase Header")
    var
        SalesInvLine: Record "Sales Invoice Line";
        //SalesHdr: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ShipLine: Record "Sales Shipment Line";
        DocAttachMgt: Codeunit "Document Attachment Mgmt";
        FromRef: RecordRef;
        ToRef: RecordRef;
        OrderLineNo: Integer;
        LineMap: Dictionary of [Integer, Integer]; // Inv Line No. -> Order Line No.
        IncDocToDocAtta: Codeunit "Incoming Doc To DocAttach";
    begin
        //if not SalesHdr.Get(SalesHdr."Document Type"::Order, OrderNo) then
        //    Error('Sales Order %1 not found.', OrderNo);
        // if SalesHdr.Status <> SalesHdr.Status::Open then
        //   Error('Sales Order %1 is not open.', OrderNo);

        // A) Copy HEADER-level attachments (Posted Sales Invoice Header -> Sales Header)
        FromRef.GetTable(SalesInvHdr);
        ToRef.GetTable(SalesHdr);
        IncDocToDocAtta.CopyAttachments(FromRef, ToRef);

        // Build a quick map from invoice line -> order line
    End;
}

