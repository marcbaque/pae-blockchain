pragma solidity ^0.4.15;

contract EventContract {
    
    enum ContractStatus {Pending, Accepted, Success, Fail}
    enum ContractorStatus {Pending, Accepted, Success, OwnerNonCompliance, ContractorNonCompliance, Failure}
    
    address owner;
    address contractor;
    address eventAddress;
    mapping(address => ContractorStatus) contractorStatus;
    uint ownerPercentatge;
    uint contractorPercentatge;
    
    string conditions;
    ContractStatus contractStatus;
    

    function EventContract(address _eventAddress, address _owner, address _contractor, uint _ownerPercentatge, 
                            uint _contractorPercentatge, string _conditions) 
    {
        eventAddress = _eventAddress;
        owner = _owner;
        contractor = _contractor;
        contractorStatus[owner] = ContractorStatus.Pending;
        contractorStatus[contractor] = ContractorStatus.Pending;
        
        ownerPercentatge = _ownerPercentatge;
        contractorPercentatge = _contractorPercentatge;
        
        conditions = _conditions;
        contractStatus = ContractStatus.Pending;
        
    }
    
    modifier onlyContractor() {
        require(msg.sender == owner || msg.sender == contractor);
        _;
    }
    modifier onlyContractorOrEvent() {
        require(msg.sender == owner || msg.sender == contractor || msg.sender == eventAddress);
        _;
    }
    modifier onlyInPending() {
        require(contractStatus == ContractStatus.Pending);
        _;
    }
    modifier onlyInAccepted() {
        require(contractStatus == ContractStatus.Accepted);
        _;
    }
    modifier onlyEvent() {
        require(msg.sender == eventAddress);
        _;
    }
    
    function accept() onlyContractor() onlyInPending returns (bool) {
        contractorStatus[msg.sender] == ContractorStatus.Accepted;
        if (contractorStatus[owner] == contractorStatus[contractor]) {
            contractStatus = ContractStatus.Accepted;
        }
        return true;
    }
    
    function success() onlyContractor() onlyInAccepted returns (bool) {
        contractorStatus[msg.sender] = ContractorStatus.Success;
        if (contractorStatus[owner] == contractorStatus[contractor]) {
            contractStatus = ContractStatus.Success;
        }
        return true;
    }
    
    function nonCompliance(ContractorStatus nonComplianceContractor) onlyContractor() onlyInAccepted returns (bool){
        if(nonComplianceContractor == ContractorStatus.OwnerNonCompliance) {
            contractorStatus[msg.sender] == ContractorStatus.OwnerNonCompliance;
        } else if (nonComplianceContractor == ContractorStatus.ContractorNonCompliance) {
             contractorStatus[msg.sender] == ContractorStatus.ContractorNonCompliance;
        } else {
            revert();
        }
        
        if (contractorStatus[owner] != ContractorStatus.Accepted && 
            contractorStatus[contractor] != ContractorStatus.Accepted) {
                
            contractStatus = ContractStatus.Fail;
                
        }
        return true;
    }

    

    function getContractStatus() onlyContractorOrEvent() constant returns(ContractStatus) {
        return contractStatus;
    }
  
}