// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Payroll {
    
    address payable public employer;
    uint public totalSalary;
    uint public totalEmployees;
    uint constant WEEK_IN_SECONDS = 604800;
    mapping(address => uint) public salaries;
    mapping(address => uint) public lastPaid;
    mapping(address => bool) public employees;
    
    constructor() {
        employer = payable(msg.sender);
        totalSalary = 0;
        totalEmployees = 0;
    }
    
    modifier onlyEmployer() {
        require(msg.sender == employer, "Only employer can call this function.");
        _;
    }
    
    function addEmployee(address employee, uint salary) public onlyEmployer {
        require(!employees[employee], "Employee already exists.");
        employees[employee] = true;
        salaries[employee] = salary;
        totalSalary += salary;
        totalEmployees++;
    }
    
    function removeEmployee(address employee) public onlyEmployer {
        require(employees[employee], "Employee does not exist.");
        employees[employee] = false;
        totalSalary -= salaries[employee];
        totalEmployees--;
    }
    
    function updateEmployeeSalary(address employee, uint salary) public onlyEmployer {
        require(employees[employee], "Employee does not exist.");
        totalSalary = totalSalary - salaries[employee] + salary;
        salaries[employee] = salary;
    }
    
    function calculatePay(address employee) public view returns (uint) {
        require(employees[employee], "Employee does not exist.");
        uint timeSinceLastPaid = block.timestamp - lastPaid[employee];
        uint weeksSinceLastPaid = timeSinceLastPaid / WEEK_IN_SECONDS;
        uint salary = salaries[employee] * weeksSinceLastPaid;
        return salary;
    }
    
    function payEmployee(address employee) public onlyEmployer {
        require(employees[employee], "Employee does not exist.");
        uint salary = calculatePay(employee);
        lastPaid[employee] = block.timestamp;
        employee.transfer(salary);
    }
    
    function getContractBalance() public view onlyEmployer returns (uint) {
        return address(this).balance;
    }
}
