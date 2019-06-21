pragma solidity >=0.4.25 <0.6.0;

contract RefrigeratedTransportation
{
    //Set of States
    enum StateType { OrderCreated, OrderConfirmed, InTransit, GoodReceived, OutOfCompliance, GoodValidated, DeliveryReady, DeliveryPickedUp, DeliveryInTransit, ClosedTransaction}
    enum SensorType { None, Farming, Transportation, Factory}
    enum GoodType { Potato, Apple, Pear}

    //List of properties
    StateType public  State;
    address public  Farmer;
    address public  Investor;
    address public  Device;
    address public  Collector;
    address public  Distributor;
    address public  PesticideSupplier;
    int public  Price;
    int public Quantity;
    int public  Deliverydate;

    constructor(int price, int quantity, time deliverydate, address farmer,address distributor) public
    {
        Farmer = farmer;
        Distributor = distributor;
        Investor = msg.sender;
        Price = price;
        Quantity = quantity;
        Deliverydate = deliverydate;
        State = StateType.OrderCreated;
    }

    function IngestTelemetry(int humidity, int temperature, int timestamp) public
    {
        // Separately check for states and sender 
        // to avoid not checking for state when the sender is the device
        // because of the logical OR
        if ( State == StateType.Completed )
        {
            revert();
        }

        if ( State == StateType.OutOfCompliance )
        {
            revert();
        }

        if (Device != msg.sender)
        {
            revert();
        }

        LastSensorUpdateTimestamp = timestamp;

        if (humidity > MaxHumidity || humidity < MinHumidity)
        {
            ComplianceSensorType = SensorType.Humidity;
            ComplianceSensorReading = humidity;
            ComplianceDetail = "Humidity value out of range.";
            ComplianceStatus = false;
        }
        else if (temperature > MaxTemperature || temperature < MinTemperature)
        {
            ComplianceSensorType = SensorType.Temperature;
            ComplianceSensorReading = temperature;
            ComplianceDetail = "Temperature value out of range.";
            ComplianceStatus = false;
        }

        if (ComplianceStatus == false)
        {
            State = StateType.OutOfCompliance;
        }
    }

    function TransferResponsibility(address newCounterparty) public
    {
        // keep the state checking, message sender, and device checks separate
        // to not get cloberred by the order of evaluation for logical OR
        if ( State == StateType.Completed )
        {
            revert();
        }

        if ( State == StateType.OutOfCompliance )
        {
            revert();
        }

        if ( InitiatingCounterparty != msg.sender && Counterparty != msg.sender )
        {
            revert();
        }

        if ( newCounterparty == Device )
        {
            revert();
        }

        if (State == StateType.Created)
        {
            State = StateType.InTransit;
        }

        PreviousCounterparty = Counterparty;
        Counterparty = newCounterparty;
    }

    function Complete() public
    {
        // keep the state checking, message sender, and device checks separate
        // to not get cloberred by the order of evaluation for logical OR
        if ( State == StateType.Completed )
        {
            revert();
        }

        if ( State == StateType.OutOfCompliance )
        {
            revert();
        }

        if (Owner != msg.sender && SupplyChainOwner != msg.sender)
        {
            revert();
        }

        State = StateType.Completed;
        PreviousCounterparty = Counterparty;
        Counterparty = 0x0000000000000000000000000000000000000000;
    }
}