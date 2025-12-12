Feature: XYZ Bank Operations

  Background:
    * configure driver = { type: 'chrome', keepSession: true, addOptions: ["--remote-allow-origins=*"]}
    Given driver 'https://www.globalsqa.com/angularJs-protractor/BankingProject/#/login'
    * def customers =
    """
    [
    { firstName: "Kyo", lastName: "Kusanagi", postCode: "L789C349" },
    { firstName: "Kyo", lastName: "Mina", postCode: "M098Q585" },
    { firstName: "Lola", lastName: "Rose", postCode: "A897N450" },
    { firstName: "Jackson", lastName: "Connely", postCode: "L789C349" },
    { firstName: "Noah", lastName: "Jay", postCode: "L789C349"}
    ]
    """
    * def addCustomer =
    """
    function(customer){
      eval("input('/html/body/div/div/div[2]/div/div[2]/div/div/form/div[1]/input', customer.firstName)")
      eval("input('/html/body/div/div/div[2]/div/div[2]/div/div/form/div[2]/input', customer.lastName)")
      eval("input('/html/body/div/div/div[2]/div/div[2]/div/div/form/div[3]/input', customer.postCode)")
      eval("click('/html/body/div/div/div[2]/div/div[2]/div/div/form/button')")
      eval("dialog(true)")
      eval("delay(1000)")
      karate.log('Added customer: ' + customer.firstName + ' ' + customer.lastName + ' - ' + customer.postCode);
    }
    """
    * def verifyCustomer =
    """
    function(customer){
      eval("input('/html/body/div/div/div[2]/div/div[2]/div/form/div/div/input', customer.firstName)")
      eval("delay(1000)")

      karate.log('Verified customer: ' + customer.firstName + ' ' + customer.lastName + ' - ' + customer.postCode);

      if (!text('/html/body/div/div/div[2]/div/div[2]/div/div').includes(customer.lastName) || !text('/html/body/div/div/div[2]/div/div[2]/div/div').includes(customer.postCode)) {
        karate.fail('Customer ' + customer.firstName + ' ' + customer.lastName + ' not found');
      }
      eval("clear('/html/body/div/div/div[2]/div/div[2]/div/form/div/div/input')")
    }
    """
    * def deleteCustomer =
    """
    function(customer){
      eval("input('/html/body/div/div/div[2]/div/div[2]/div/form/div/div/input', customer.firstName)")
      eval("delay(1000)")
      eval("click('/html/body/div/div/div[2]/div/div[2]/div/div/table/tbody/tr[1]/td[5]/button')")
      eval("clear('/html/body/div/div/div[2]/div/div[2]/div/form/div/div/input')")

      karate.log('Deleted customer: ' + customer.firstName + ' ' + customer.lastName + ' - ' + customer.postCode);
    }
   """

    * def txn =
    """
    [
    { amount: 50000, txnType: "credit" },
    { amount: 3000, txnType: "debit" },
    { amount: 2000, txnType: "debit" },
    { amount: 5000, txnType: "credit" },
    { amount: 10000, txnType: "debit" },
    { amount: 15000, txnType: "debit" },
    { amount: 1500, txnType: "credit" }
    ]
    """
    * def balance = 0
    * def txnSteps =
    """
    function(txn){
      if (txn.txnType == 'credit') {
        eval("click('/html/body/div/div/div[2]/div/div[3]/button[2]')")
        eval("delay(1000)")
        eval("input('/html/body/div/div/div[2]/div/div[4]/div/form/div/input', txn.amount.toString())")
        eval("click('/html/body/div/div/div[2]/div/div[4]/div/form/button')")

        balance = balance + txn.amount;
      }

      else if (txn.txnType == 'debit') {
        eval("click('/html/body/div/div/div[2]/div/div[3]/button[3]')")
        eval("delay(1000)")
        eval("input('/html/body/div/div/div[2]/div/div[4]/div/form/div/input', txn.amount.toString())")
        eval("click('/html/body/div/div/div[2]/div/div[4]/div/form/button')")

        balance = balance - txn.amount;
      }

      var actualBalance = text('/html/body/div/div/div[2]/div/div[2]/strong[2]')
      karate.log(txn.txnType + ' transaction: ' + txn.amount.toString() + ' Expected balance: ' + balance + ', Actual balance: ' + actualBalance);

      if (actualBalance != balance.toString()) {
        karate.fail('Balance mismatch');
      }

      eval("delay(1000)")
    }
    """

    @Q2
  Scenario: As a bank manager, I want to add, read and delete customer
    #Login as bank manager
    Given click("/html/body/div/div/div[2]/div/div[1]/div[2]/button")
    And delay(1000)
    Then match driver.url == 'https://www.globalsqa.com/angularJs-protractor/BankingProject/#/manager'

    #Select add customer
    When click("/html/body/div/div/div[2]/div/div[1]/button[1]")
    And delay(1000)

    #Add customers
    When karate.forEach(customers, addCustomer)

    #Verify added customers
    And click("/html/body/div/div/div[2]/div/div[1]/button[3]")
    Then karate.forEach(customers, verifyCustomer)

    #Delete specific customers
    Given karate.forEach(customers.slice(3,5), deleteCustomer)

    #Verify remaining customers
    And click("/html/body/div/div/div[2]/div/div[1]/button[1]")
    And delay(1000)
    And click("/html/body/div/div/div[2]/div/div[1]/button[3]")
    Then karate.forEach(customers.slice(0,3), verifyCustomer)

      @Q3
  Scenario: As a customer, I want to perform deposit and withdrawal transaction
    #Login as customer
    Given click("/html/body/div/div/div[2]/div/div[1]/div[1]/button")
    And delay(1000)
    Then match driver.url == 'https://www.globalsqa.com/angularJs-protractor/BankingProject/#/customer'

    #Select name
    Given select("//*[@id='userSelect']", 1)
    And delay(1000)
    And click("/html/body/div/div/div[2]/div/form/button")

    #Select account
    When select("//*[@id='accountSelect']", 2)
    And delay(1000)

    #Verify balance 0
    Then match text("/html/body/div/div/div[2]/div/div[2]/strong[2]") == '0'

    #Perform transaction
    Given karate.forEach(txn, txnSteps)