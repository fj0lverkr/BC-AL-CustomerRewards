page 50101 "Reward Level List"
{
    PageType = List;
    //ContextSensitiveHelpPage = 'sales-rewards';
    SourceTable = "Reward Level";
    SourceTableView = sorting("Minimum Reward Points") order(ascending);

    layout
    {
        area(content)
        {
            repeater(group)
            {
                field(Level; Rec.Level)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the level of reward that the customer has at this point.';
                }
                field("Minimum Reward Points"; Rec."Minimum Reward Points")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of points a customer must have to reach this level.';
                }
            }
        }
    }

    var
        CustomerRewardsExtMgt: Codeunit "Customer Rewards Ext Mgt";
        NotActivatedTxt: Label 'Customer Rewards feature is not activated.';

    trigger OnOpenPage();
    begin
        if not CustomerRewardsExtMgt.IsCustomerRewardsActivated then
            Error(NotActivatedTxt);
    end;
}