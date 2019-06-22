pragma solidity >=0.4.25 <0.6.0;

contract FoodTransparency
{
    //Set of States
    enum StateType {OrderCreated, OrderConfirmed, InTransit, GoodReceived, OutOfCompliance, GoodValidated, DeliveryReady, DeliveryPickedUp, DeliveryInTransit, ClosedTransaction}
    enum SensorType {Farming, Transportation, Factory}

    //List of properties
    StateType public State;
    address public Farmer;
    address public Investor;
    address public Device;
    address public Collector;
    address public Distributor;
    address public PesticideSupplier;
    int public Price;
    int public Quantity;
    int public DeliveryDate;
    int public Humidity;
    int public Temperature;
    int public Accelerometer;
    int public Gyroscope;
    int public DeviceTimestamp;
    SensorType public Sensor;
    string public Activity;
    int public PesticideCounter;

    constructor(int price, int quantity, int deliveryDate, address farmer, address distributor, address device, address pesticideSupplier) public
    {
        State = StateType.OrderCreated;
        Farmer = farmer;
        Device = device;
        Investor = msg.sender;
        Distributor = distributor;
        PesticideSupplier = pesticideSupplier;
        Price = price;
        Quantity = quantity;
        DeliveryDate = deliveryDate;
        Humidity = 0;
        Temperature = 0;
        Accelerometer = 0;
        Gyroscope = 0;
        PesticideCounter = 0;
        DeviceTimestamp = 0;
    }

    function IngestTelemetry(int humidity, int temperature, int gyroscope, int accelerometer, int timestamp) public
    {
        // Separately check for states and sender 
        // to avoid not checking for state when the sender is the device
        // because of the logical OR
        if ( State == StateType.ClosedTransaction )
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

        if (State == StateType.OrderConfirmed){
            Sensor = SensorType.Farming;
            Humidity = humidity;
            Temperature = temperature;
        }

        if (State == StateType.InTransit || State == StateType.DeliveryInTransit){
            Sensor = SensorType.Transportation;
            Accelerometer = accelerometer;
            Gyroscope = gyroscope;
        }

        if(State == StateType.GoodValidated){
            Sensor = SensorType.Factory;
            Humidity = humidity;
            Temperature = temperature;
        }

        DeviceTimestamp = timestamp;
    }

    function Confirm(bool answer) public
    {
        // keep the state checking, message sender, and device checks separate
        // to not get cloberred by the order of evaluation for logical OR
        if ( State == StateType.ClosedTransaction )
        {
            revert();
        }

        if ( State == StateType.OutOfCompliance )
        {
            revert();
        }

        if ( Farmer != msg.sender)
        {
            revert();
        }

        if (answer == true)
        {
            State = StateType.OrderConfirmed;
        }
        else {
            State = StateType.ClosedTransaction;
        }
    }

    function StartGoodDelivery(address distributor) public
    {
        if ( State == StateType.ClosedTransaction )
        {
            revert();
        }

        if ( State == StateType.OutOfCompliance )
        {
            revert();
        }

        if ( Farmer != msg.sender)
        {
            revert();
        }

        Distributor = distributor;
        State = StateType.InTransit;
    }

    function ReportActivity(string activity) public
    {
        if ( State == StateType.ClosedTransaction )
        {
            revert();
        }

        if ( State == StateType.OutOfCompliance )
        {
            revert();
        }

        if ( Farmer != msg.sender)
        {
            revert();
        }

        Activity = activity;
    }

    function ReportID(address identity) public
    {
        if ( State == StateType.ClosedTransaction )
        {
            revert();
        }

        if ( State == StateType.OutOfCompliance )
        {
            revert();
        }

        if ( PesticideSupplier != msg.sender)
        {
            revert();
        }

        if ( identity == Farmer)
        {
            PesticideCounter++;
        }
    }

    function Validate() public
    {
        if ( State == StateType.ClosedTransaction )
        {
            revert();
        }

        if ( State == StateType.OutOfCompliance )
        {
            revert();
        }

        if ( Collector != msg.sender)
        {
            revert();
        }

        State = StateType.GoodReceived;
    }

    function CheckQuality(bool quality) public
    {
        if ( State == StateType.ClosedTransaction )
        {
            revert();
        }

        if ( State == StateType.OutOfCompliance )
        {
            revert();
        }

        if ( Collector != msg.sender)
        {
            revert();
        }

        if (quality) {
            State = StateType.GoodValidated;
        }
        else {
            State = StateType.OutOfCompliance;
        }
    }

    function CompleteProcessing() public
    {
        if ( State == StateType.ClosedTransaction )
        {
            revert();
        }

        if ( State == StateType.OutOfCompliance )
        {
            revert();
        }

        if ( Collector != msg.sender)
        {
            revert();
        }

        State = StateType.DeliveryReady;
    }

    function ConfirmPickUp() public
    {
        if ( State == StateType.ClosedTransaction )
        {
            revert();
        }

        if ( State == StateType.OutOfCompliance )
        {
            revert();
        }

        if ( Distributor != msg.sender)
        {
            revert();
        }

        State = StateType.DeliveryPickedUp;
    }

    function StartDelivery() public
    {
        if ( State == StateType.ClosedTransaction )
        {
            revert();
        }

        if ( State == StateType.OutOfCompliance )
        {
            revert();
        }

        if ( Distributor != msg.sender)
        {
            revert();
        }

        State = StateType.DeliveryInTransit;
    }

    function ConfirmDelivery(bool goodQuality) public
    {
        if ( State == StateType.ClosedTransaction )
        {
            revert();
        }

        if ( State == StateType.OutOfCompliance )
        {
            revert();
        }

        if ( Investor != msg.sender)
        {
            revert();
        }

        if (goodQuality) {
            State = StateType.ClosedTransaction;
        }
        else {
            State = StateType.OutOfCompliance;
        }
    }
}