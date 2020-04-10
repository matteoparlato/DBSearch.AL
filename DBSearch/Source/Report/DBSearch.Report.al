report 50100 "DB Search"
{
    UsageCategory = None;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Field; Field)
        {
            RequestFilterFields = Type, Len, TableNo, FieldName;

            trigger OnPreDataItem()
            begin
                if DBSearch.FindLast() then
                    NextEntryNo := DBSearch."Entry No." + 10000
                else
                    NextEntryNo := 0;

                ProgressDialog.OPEN('Searching in table: ############1', TableNo);

                if GetFilter(TableNo) = '' then
                    SetFilter(TableNo, '1..1000000000');

                SetRange(Enabled, true);
                SetRange(Class, Class::Normal);
                SetRange(ObsoleteState, ObsoleteState::No);
            end;

            trigger OnAfterGetRecord()
            var
                RecRef: RecordRef;
                FldRed: FieldRef;
            begin
                if TableNo <> DATABASE::"DB Search" then begin
                    RecRef.Open(TableNo);

                    ProgressDialog.Update(1, TableNo);

                    FldRed := RecRef.Field("No.");
                    FldRed.SetFilter(Pattern);
                    if RecRef.FindFirst() then
                        repeat
                            FldRed := RecRef.Field("No.");

                            NextEntryNo += 10000;

                            DBSearch.Init();
                            DBSearch."Entry No." := NextEntryNo;
                            DBSearch."Record ID" := RecRef.RecordId;
                            DBSearch."Table No." := TableNo;
                            DBSearch."Table Name" := TableName;
                            DBSearch."Field No." := "No.";
                            DBSearch."Field Name" := FieldName;
                            Evaluate(DBSearch."Current Value", Format(FldRed.Value));
                            DBSearch."Correct Value" := DBSearch."Current Value";

                            DBSearch.Insert();
                        until RecRef.Next() = 0;
                    RecRef.Close();
                end;
            end;

            trigger OnPostDataItem()
            begin
                ProgressDialog.Close();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field(SearchPattern; Pattern)
                    {
                        Caption = 'Text to search';
                        ToolTip = 'The value to search in tables.';
                        ApplicationArea = All;
                    }
                    field(UnlockPassword; Password)
                    {
                        Caption = 'Password';
                        ToolTip = 'The password to unlock the report execution.';
                        ApplicationArea = All;
                    }
                }
            }
        }

        trigger OnOpenPage()
        var
            Tip: Notification;
        begin
            Tip.Message := 'Tip: You can use special symbols (or operators) to further filter the results.';
            Tip.Scope := NotificationScope::LocalScope;
            Tip.Send();
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        var
            TypeFilter: Text;
        begin
            if CloseAction = Action::OK then begin
                CheckPassword();

                // Type filter is mandatory
                if Field.GetFilter(Type) = '' then
                    Field.TestField(Type);

                // Len filter is mandatory with 
                TypeFilter := Field.GetFilter(Type);
                if TypeFilter.Contains('Code') or TypeFilter.Contains('Text') then
                    if (Field.GetFilter(Len) = '') then
                        Field.TestField(Len);
            end;
        end;
    }

    [NonDebuggable]
    local procedure CheckPassword()
    var
        Text001Txt: TextConst ENU = 'The specified password is not correct.', ITA = 'La password specificata non è corretta';
    begin
        if Password <> 'a8a0c8e9-bdc8-4719-9e3b-3114328830af' then
            Error(Text001Txt);
    end;

    var
        DBSearch: Record "DB Search";
        Pattern: Text;
        Password: Text;
        NextEntryNo: Integer;
        ProgressDialog: Dialog;
}