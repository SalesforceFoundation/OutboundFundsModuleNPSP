# UnitTest

`UnitTest` is a unit-testing framework based on the API and use of Python's [unittest.mock](https://docs.python.org/3/library/unittest.mock.html).

-   When an instance is mocked, all of the instance's methods automatically have a mock created and associated with the instance method.
-   Set and get a mock `returnValue` with a `UnitTest.Mock` property.
-   Have a mocked method throw an Exception by setting its `returnValue` as an instance of an Exception or an Exception Type.
-   Add custom logic of what a `UnitTest.Mock` will return when called by creating an extension of `UnitTest.Mock` and overriding the [sideEffect](#sideeffect) method.
-   Assert the `UnitTest.Mock` was called or not called using assert API:

# UnitTest.Mock

`UnitTest.Mock` provides a core Mock class removing the need to create a host of stubs throughout your test suite. After performing an action, you can make assertions about which methods / attributes were used and arguments they were called with. You can also specify return values and set needed attributes in the normal way.

**Attributes**

-   `Object returnValue`
    -   The return value of the method called.
    -   Default: `null`
    -   If the `returnValue` is an instance of an `Exception`, the exception is thrown.
    -   If the `returnValue` is an exception type, a new instance of the exception type is thrown.
-   `Map<String, UnitTest.Mock> methods`
    -   Map of [UnitTest.Mock](#unittestmock) by method name for stubs of this mock.
    -   Edit at your own risk.
-   `List<List<Object>> calls`
    -   List of each call's arguments (i.e. `List<Object>`).
    -   If a method is [overloaded](https://salesforce.stackexchange.com/questions/165127/overloading-method-return-type-in-apex), the number of arguments may differ between calls.

**Methods**

-   [getMethod(String methodName)](#getmethod)
    -   Returns the `UnitTest.Mock` associated with the `methodName`. If the `methodName` does not have an associated `UnitTest.Mock`, a new `UnitTest.Mock` is constructed for `methodName` and returned.
-   [setMethod(String methodName, UnitTest.Mock mock)](#setmethod)
    -   Overrides the default UnitTest.Mock associated with `methodName`. Remember, if `mock` is null, [getMethod](#getmethod) will create a new UnitTest.Mock associated with methodName.
-   [sideEffect(Object instance, String methodName, Type returnType, List<Type> parameterTypes, List<String> parameterNames, List<Object> arguments)](#sideeffect)
    -   Returns what `handleMethodCall` will return. If `sideEffect` returns a [stub provider](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_interface_System_StubProvider.htm), `handleMethodCall` will try return a stub of the stub provider with the `returnType` argument. Default: returns `returnValue`.

## getMethod

Returns the `UnitTest.Mock` associated with the `methodName`. If the `methodName` does not have an associated `UnitTest.Mock`, a new `UnitTest.Mock` is constructed for `methodName` and returned.

### Parameters

#### methodName

Type: [String](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_string.htm)

Name of method to mock. Cannot be null.

### Return Value

Type: [UnitTest.Mock](#unittestmock)

UnitTest.Mock for the `methodName`.

### Example

```apex
public interface MyService {

    String getName();
    Integer getInteger();

}

@IsTest
public with sharing class MyService_TEST {

    @IsTest
    private static void stubGetName() {
        final UnitTest.Mock myServiceMock = new UnitTest.Mock();

        myServiceMock.getMethod('getName').returnValue = 'Random' + Crypto.getRandomInteger();

        // REMEMBER: myServiceMock.getMethod('getName') is a UnitTest.Mock
        // automatically created.

        Test.startTest();

        final MyService myService = (MyService) myServiceMock.createStub(MyService.class);

        final String actualName = myService.getName();
        final Integer actualInteger = myService.getInteger();

        Test.stopTest();

        System.assertEquals(
            myServiceMock.getMethod('getName').returnValue,
            actualName,
        );

        // REMEMBER: UnitTest.Mock.return value defaults to `null`.
        System.assertEquals(
            null,
            myServiceMock.getMethod('getInteger').returnValue
        );

        System.assertEquals(
            actualInteger,
            myServiceMock.getMethod('getInteger').returnValue
        );
    }
}

```

## setMethod

Overrides the default UnitTest.Mock associated with `methodName`. Remember, if `mock` is null, [getMethod](#getmethod) will create a new UnitTest.Mock associated with methodName.

### Parameters

#### methodName

Type: [String](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_string.htm)

Name of method to mock. Cannot be null.

#### mock

Type: [UnitTest.Mock](#unittestmock)

Mock for the method. Remember, if mock is null, getMethod will create a new UnitTest.Mock associated with methodName.

### Return Value

Type: void

### Example

```apex
public interface MyService {

    String getName();
    Integer getInteger();

}

@IsTest
public with sharing class MyService_TEST {

    @IsTest
    private static void stubGetName() {
        final UnitTest.Mock myServiceMock = new UnitTest.Mock();

        final UnitTest.Mock getNameMock = new UnitTest.Mock();

        myServiceMock.setMethod(`getName`, getNameMock);

        System.assert(
            getNameMock === myServiceMock.getMethod('getName'),
            `The mock for getName should have the same memory location (===) as getNameMock`
        );
    }
}
```

## sideEffect

Virtual method that returns what `handleMethodCall` will return. If `sideEffect` returns a [stub provider](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_interface_System_StubProvider.htm), `handleMethodCall` will try return a stub of the stub provider with the `returnType` argument.

Default: returns `returnValue`.

### Parameters

#### instance

Type: Object

`instance` of the [handleMethodCall](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_interface_System_StubProvider.htm#apex_System_StubProvider_handleMethodCall)

#### methodName

Type: [String](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_string.htm#apex_methods_system_string)

`methodName` of the [handleMethodCall](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_interface_System_StubProvider.htm#apex_System_StubProvider_handleMethodCall)

#### returnType

Type: [System.Type](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_type.htm#apex_methods_system_type)

`returnType` of the [handleMethodCall](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_interface_System_StubProvider.htm#apex_System_StubProvider_handleMethodCall)

#### parameterTypes

Type: [List<System.Type>](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_type.htm#apex_methods_system_type)

`parameterTypes` of the [handleMethodCall](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_interface_System_StubProvider.htm#apex_System_StubProvider_handleMethodCall)

#### parameterNames

Type: [List<String>](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_string.htm#apex_methods_system_string)

`parameterNames` of the [handleMethodCall](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_interface_System_StubProvider.htm#apex_System_StubProvider_handleMethodCall)

#### arguments

Type: List<Object>

`arguments` of the [handleMethodCall](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_interface_System_StubProvider.htm#apex_System_StubProvider_handleMethodCall)

### Return Value

Type: Object

What `handleMethodCall` will return. If an instance of an Exception or an Exception Type is returned, the exception instance or a new instance of the Exception Type is thrown. If a [System.StubProvider](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_interface_System_StubProvider.htm#apex_System_StubProvider_handleMethodCall) is returned, a stub of the [System.StubProvider](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_interface_System_StubProvider.htm#apex_System_StubProvider_handleMethodCall) is returned. Default: returns `returnValue`.
