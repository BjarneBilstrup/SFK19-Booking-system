page 50100 "BAL Resource Booking"
{
    ApplicationArea = Jobs;
    Caption = 'Booking';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = ListPlus;
    RefreshOnActivate = true;
    SaveValues = false;
    SourceTable = Resource;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Matrixindstillinger)
            {
                Caption = 'Matrix Options';
            }
            field(StartDate; StartDate)
            {
                ApplicationArea = Jobs;
                CaptionMl = ENU = 'Startdate', DAN = 'Startdato';
                ToolTip = 'Specifies the startdate of the matrix.';

                trigger OnValidate()
                begin
                    SetColumnsStartDate(SetWanted::Same);
                    UpdateMatrixSubform;
                    //OnlyFree := false;
                    //UpdateOnlyfreeMatrixSubform;
                end;
            }
            field(OnlyFree; OnlyFree)
            {
                ApplicationArea = Jobs;
                CaptionML = ENU = 'Only Free', DAN = 'Kun ledige';
                ToolTip = 'Viser kun ressourcder som er ledige på "Startdato"/Første dato i visningen';

                trigger OnValidate()
                begin
                    UpdateOnlyfreeMatrixSubform;
                end;
            }
            part(MatrixForm; "BAL Resource Booking Matrix")
            {
                ApplicationArea = Jobs;
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Previous Set")
            {
                ApplicationArea = Jobs;
                CaptionML = ENU = 'Previous set', DAN = 'Forrige datoer';
                Image = PreviousSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Go to the previous set of data.';

                trigger OnAction()
                begin
                    SetColumns(SetWanted::Previous);
                    UpdateMatrixSubform;
                end;
            }
            action("Previous Column")
            {
                ApplicationArea = Jobs;
                CaptionML = ENU = 'Previous column', DAN = 'Forrige kolonne';
                Image = PreviousRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Go to the previous column.';

                trigger OnAction()
                begin
                    SetColumns(SetWanted::PreviousColumn);
                    UpdateMatrixSubform;
                end;
            }
            action("Next Column")
            {
                ApplicationArea = Jobs;
                CaptionML = ENU = 'Next column', DAN = 'Næste kolonne';
                Image = NextRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Go to the next column.';

                trigger OnAction()
                begin
                    SetColumns(SetWanted::NextColumn);
                    UpdateMatrixSubform;
                end;
            }
            action("Next Set")
            {
                ApplicationArea = Jobs;
                CaptionML = ENU = 'Next set', DAN = 'Næste datoer';
                Image = NextSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Go to the next set of data.';

                trigger OnAction()
                begin
                    SetColumns(SetWanted::Next);
                    UpdateMatrixSubform;
                end;
            }
            action("Report1")
            {
                ApplicationArea = Jobs;
                Caption = 'Booking rapport';
                Image = Report;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Booking Rapport ';

                trigger OnAction()
                begin
                    Report.run(50100);
                end;
            }
            action("Report2")
            {
                ApplicationArea = Jobs;
                Caption = 'Booking detalje';
                Image = Report;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Booking detalje med noter ';

                trigger OnAction()
                begin
                    Report.run(50101);
                end;
            }
            action("Booking Matrix")
            {
                ApplicationArea = Jobs;
                Caption = 'Booking Matrix';
                Image = Report;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Booking Matrix ';

                trigger OnAction()
                begin
                    Report.run(50102);
                end;
            }
            action("Create booking order")
            {
                ApplicationArea = Jobs;
                Caption = 'Create Booking Order';
                Image = Report;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Booking Matrix ';

                trigger OnAction()
                var
                    Resource2: record Resource;
                    SalesHeader: record "Sales Header";
                    Salesline: Record "Sales Line";
                    BALGetDateToDialog: page "BAL Get Date To Dialog";
                    Datefield: Date;
                    DateTofield: Date;
                    StartTime: Time;
                    EndTime: Time;
                    CustomerNo: Code[20];
                    SalesHeaderNo: Code[20];

                begin
                    CurrPage.SetSelectionFilter(Resource2);
                    BALGetDateToDialog.runmodal;
                    BALGetDateToDialog.Getdata(datefield, dateTofield, Starttime, EndTime, CustomerNo, SalesheaderNo);


                    if SalesHeaderNo <> '' then
                        SalesHeader.get(SalesHeader."Document Type"::Order, SalesHeaderNo)
                    else begin
                        SalesHeader.init;
                        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
                        SalesHeader."Shipment Date" := StartDate;
                        salesheader.insert(true);
                        SalesHeader.Validate("Sell-to Customer No.", customerno);
                        SalesHeader.modify;
                    end;

                    Salesline.setrange("Document Type", SalesHeader."Document Type");
                    Salesline.setrange("Document No.", SalesHeader."No.");
                    if not salesline.findlast then begin
                        Salesline."Document Type" := SalesHeader."Document Type";
                        Salesline."Document No." := SalesHeader."No.";
                    end;

                    Resource2.FindFirst();
                    message('%1', Resource2.count);
                    repeat
                        Salesline."Line No." += 10000;
                        Salesline.validate(type, Salesline.type::Resource);
                        Salesline.validate("No.", Resource2."No.");
                        Salesline.validate(Quantity, 1);
                        Salesline."Shipment Date" := Datefield;
                        if Salesline."No." > '' then begin
                            Salesline."BAL Start time" := StartTime;
                            Salesline."BAL ending time" := EndTime;
                        end;
                        salesline.insert;


                    until Resource2.next = 0;

                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        SetColumns(SetWanted::Initial);
        UpdateMatrixSubform;
    end;

    var
        MatrixRecords: array[7] of Record Date;
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        MatrixColumnCaptions: array[7] of Text[1024];
        ColumnSet: Text[1024];
        SetWanted: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn;
        PKFirstRecInCurrSet: Text[100];
        CurrSetLength: Integer;
        StartDate: Date;
        OnlyFree: Boolean;

    procedure SetColumns(SetWanted: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn)
    var
        MatrixMgt: Codeunit "Matrix Management";
        i: Integer;
    begin
        MatrixMgt.GeneratePeriodMatrixData(SetWanted, 7, true, PeriodType, '', PKFirstRecInCurrSet, MatrixColumnCaptions, ColumnSet, CurrSetLength, MatrixRecords);
        for i := 1 to ARRAYLEN(MatrixRecords) do begin
            MatrixColumnCaptions[i] := format(matrixrecords[i]."Period Start") + ' ' + MatrixColumnCaptions[i];
        end;
    end;

    procedure SetColumnsStartDate(SetWanted: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn)
    var
        MatrixMgt: Codeunit "Matrix Management";
        i: Integer;
    begin
        PKFirstRecInCurrSet := 'Period Type=CONST(Date),Period Start=CONST(' + Format(StartDate) + ')';
        MatrixMgt.GeneratePeriodMatrixData(SetWanted, 7, True, PeriodType, '', PKFirstRecInCurrSet, MatrixColumnCaptions, ColumnSet, CurrSetLength, MatrixRecords);
        for i := 1 to ARRAYLEN(MatrixRecords) do begin
            MatrixColumnCaptions[i] := format(matrixrecords[i]."Period Start") + ' ' + MatrixColumnCaptions[i];
        end;
    end;

    local procedure UpdateMatrixSubform()
    begin
        CurrPage.MatrixForm.PAGE.Load(MatrixColumnCaptions, MatrixRecords, CurrSetLength);
        CurrPage.UPDATE(FALSE);
    end;

    local procedure UpdateOnlyfreeMatrixSubform()
    begin
        CurrPage.MatrixForm.PAGE.SetOnlyfree(OnlyFree);
        CurrPage.UPDATE(FALSE);
    end;
}
