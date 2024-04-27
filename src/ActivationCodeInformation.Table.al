table 50101 "Activation Code Information"
{
    Caption = 'Activation Code Information';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; ActivationCode; Text[14])
        {
            Caption = 'Activation Code';
            DataClassification = SystemMetadata;
            Description = 'Activation code used by the user to activate the Customer Rewards feature.';
        }
        field(2; "Activation Date"; Date)
        {
            Caption = 'Activation Date';
            DataClassification = SystemMetadata;
            Description = 'Date the Customer Rewards feature was activated.';
        }
        field(3; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = SystemMetadata;
            Description = 'Date the Customer Rewards feature expires.';
        }
    }
    keys
    {
        key(PK; ActivationCode)
        {
            Clustered = true;
        }
    }
}