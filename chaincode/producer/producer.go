package main

import (
    "fmt"
    "github.com/hyperledger/fabric/core/chaincode/shim"
    pb "github.com/hyperledger/fabric/protos/peer"
    "encoding/json"
)

type Producer struct {
}

type PC struct {
    Snumber string
    Serie string
    Others string
    Status string
}

// Implement Init
func (c *Producer) Init(stub shim.ChaincodeStubInterface) pb.Response { 
/*    creatorByte, err := stub.GetCreator()
    if(err != nil) {
        return shim.Error("GetCreator err")
    }
    stub.PutState(string(creatorByte), []byte("producer"))
*/
    return shim.Success(nil) 
}

func (c *Producer) Invoke(stub shim.ChaincodeStubInterface) pb.Response { 

    function, args := stub.GetFunctionAndParameters()

    switch function {
	case "createPC":
		return c.createPC(stub, args)
    case "updateStatus":
        return c.updateStatus(stub, args)
    case "queryDetail":
        return c.queryDetail(stub, args)
    default:
        return shim.Error("Functions: createPC, updateStatus, queryDetail")
    }
}

// createPC puts an available PC in the Blockchain
func (c *Producer) createPC(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	
	if len(args) != 3 {
		return shim.Error("createPC arguments usage: Serialnumber, Serie, Others")
	}

	// A newly created computer is available
	pc := PC{args[0], args[1], args[2], "available"} 

	// Use JSON to store in the Blockchain
	pcAsBytes, err := json.Marshal(pc)

	if err != nil {
		return shim.Error(err.Error())
	}

	// Use serial number as key
	err = stub.PutState(pc.Snumber, pcAsBytes)

	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(nil)
}

// updateStatus handles sell and hand back
func (c *Producer) updateStatus(stub shim.ChaincodeStubInterface, args []string) pb.Response {
    if len(args) != 2 {
        return shim.Error("This function needs the serial number and the new status as arguments")
    }

    // Look for the serial number
    v, err := stub.GetState(args[0])
    if err != nil {
        return shim.Error("Serialnumber " + args[0] + " not found ")
    }

    // Get Information from Blockchain
    var pc PC
    // Decode JSON data
    json.Unmarshal(v, &pc)

    // Change the status
    pc.Status = args[1] 
    // Encode JSON data
    pcAsBytes, err := json.Marshal(pc)

    // Store in the Blockchain
    err = stub.PutState(pc.Snumber, pcAsBytes)
    if err != nil {
        return shim.Error(err.Error())
    }

    return shim.Success(nil)
}

// queryDetail gives all fields of stored data and wants to have the serial number
func (c *Producer) queryDetail(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	
	// Look for the serial number
	value, err := stub.GetState(args[0])
	if err != nil {
		return shim.Error("Serial number " + args[0] + " not found")
	}

	var pc PC
	// Decode value
	json.Unmarshal(value, &pc)

	fmt.Print(pc)
	// Response info
	return shim.Success([]byte(" SNMBR: " + pc.Snumber + " Serie: " + pc.Serie + " Others: " + pc.Others + " Status: " + pc.Status))
}

func main() {
    err := shim.Start(new(Producer))
    if err != nil {
        fmt.Printf("Error starting chaincode sample: %s", err)
    }
}