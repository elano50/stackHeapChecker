//
//  AppDelegate.swift
//  stackHeapChecker
//
//  Created by Aleksandr Kisel on 23.06.2021.
//

import Cocoa
import AppKit

class TestClass {
  let int = 1
}

protocol P {
  func a()
}

func hexString(bytes: [UInt8]) -> String  {
  var result = ""
  
  for (index, byte) in bytes.reversed().enumerated() {
    if index > 0 && index % 8 == 0 {
      result.append(" 0x")
    }
    result.append(String(format: "%02x", byte))
  }
  
  return "0x" + result
}

func printPointer<T>(ptr: UnsafePointer<T>) {
  let size = MemoryLayout<T>.size
  
  let bytes = ptr.withMemoryRebound(to: UInt8.self, capacity: size) {
    Array(UnsafeBufferPointer(start: $0, count: size))
  }
  
  let ptrAddress = ptr.debugDescription
  let ptrValue = hexString(bytes: bytes)
  
  let ptrAddressPrefix = String(ptrAddress.prefix(8))
  
  var testClass = TestClass()
  
  var isHeap = false
  var isStack = false
  
  withUnsafePointer(to: &testClass) { classPtr in
    let size = MemoryLayout<TestClass>.size
    
    let classBytes = classPtr.withMemoryRebound(to: UInt8.self, capacity: size) {
      Array(UnsafeBufferPointer(start: $0, count: size))
    }
    
    let heapAddress = hexString(bytes: classBytes)
    let heapAddressPrefix = String(heapAddress.prefix(8))
    
    isHeap = heapAddressPrefix == ptrAddressPrefix
    
    if !isHeap {
      let stackAddressPrefix = String(classPtr.debugDescription.prefix(8))
      isStack = stackAddressPrefix == ptrAddressPrefix
    }
    
    print(ptrAddress + ": " + ptrValue + " - " + (isStack ? "stack" : (isHeap ? "heap" : "unknown")))
  }
  
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    emptyStruct()
    emptyStructInsideClosure()
    simpleStruct()
    simpleStructInsideClosure()
    structWithClassProperty()
    structAsClassProperty()
    emptyStructAsClassProperty()
    structInsideArray()
    structAsDictValue()
    structAsTupleValue()
    structAsEnumAssociatedValue()
    structWithStruct()
    structWithProtocolValues()
    simpleString()
    
  }
  
  
  func emptyStruct() {
    struct EmptyStruct { }
    
    var a = EmptyStruct()
    
    withUnsafePointer(to: &a) {
      print("\n-----------  Empty Struct  ------------")
      printPointer(ptr: $0)
    }
  }
  
  func emptyStructInsideClosure() {
    struct EmptyStruct { }
    
    var a = EmptyStruct()
    
    withUnsafePointer(to: &a) {
      print("\n-----------  Empty Struct inside closure  ------------")
      printPointer(ptr: $0)
    }
    
    let closure = {
      _ = a
    }
    
    closure()
  }
  
  func simpleStruct() {
    struct SimpleStruct {
      let int = 1
    }
    
    var a = SimpleStruct()
    
    withUnsafePointer(to: &a) {
      print("\n-----------  Simple Struct  ------------")
      printPointer(ptr: $0)
    }
  }
  
  func simpleStructInsideClosure() {
    struct SimpleStruct {
      let int = 1
    }
    
    var a = SimpleStruct()
    
    withUnsafePointer(to: &a) {
      print("\n-----------  Simple Struct inside closure  ------------")
      printPointer(ptr: $0)
    }
    
    let closure = {
      _ = a
    }
    
    closure()
  }
  
  func structWithClassProperty() {
    
    class SimpleClass {
      let int = 1
    }
    
    struct StructWithClassProperty {
      let int = 1
      let simpleClass = SimpleClass()
    }
    
    var a = StructWithClassProperty()
    
    withUnsafePointer(to: &a) {
      print("\n-----------  Struct with Class property ------------")
      printPointer(ptr: $0)
    }
  }
  
  func structAsClassProperty() {
    
    struct SimpleStruct {
      let int = 2
    }
    
    class ClassWithStruct {
      let int = 1
      var simpleStruct = SimpleStruct()
    }
    
    withUnsafePointer(to: &ClassWithStruct().simpleStruct) {
      print("\n-----------  Struct as Class property ------------")
      printPointer(ptr: $0)
    }
  }
  
  func emptyStructAsClassProperty() {
    
    struct EmptyStruct {
    }
    
    class ClassWithStruct {
      let int = 1
      var emptyStruct = EmptyStruct()
    }
    
    withUnsafePointer(to: &ClassWithStruct().emptyStruct) {
      print("\n-----------  Empty Struct as Class property ------------")
      printPointer(ptr: $0)
    }
  }
  
  func structInsideArray() {
    struct SimpleStruct {
      let int = 2
    }
    
    var arr = [SimpleStruct()]
    
    withUnsafePointer(to: &arr[0]) {
      print("\n-----------  Struct inside Array ------------")
      printPointer(ptr: $0)
    }
  }
  
  func structAsDictValue() {
    struct SimpleStruct {
      let int = 2
    }
    
    var dict = ["1": SimpleStruct()]
    
    withUnsafePointer(to: &dict["1"]) {
      print("\n-----------  Struct inside Dict ------------")
      printPointer(ptr: $0)
    }
  }
  
  func structAsTupleValue() {
    struct SimpleStruct {
      let int = 2
    }
    
    var tuple = (1, SimpleStruct())
    
    withUnsafePointer(to: &tuple.1) {
      print("\n-----------  Struct inside tuple ------------")
      printPointer(ptr: $0)
    }
  }
  
  func structAsEnumAssociatedValue() {
    struct SimpleStruct {
      let int = 2
    }
    
    enum TestEnum {
      case test(SimpleStruct)
    }
    
    var enumValue: TestEnum = .test(SimpleStruct())
    
    withUnsafePointer(to: &enumValue) {
      print("\n-----------  Struct as enum associated value ------------")
      printPointer(ptr: $0)
    }
    
  }
  
  func structWithStruct() {
    struct SimpleStruct {
      let int = 1
    }
    
    struct ComplexStruct {
      let a = SimpleStruct()
    }
    
    var a = ComplexStruct()
    
    withUnsafePointer(to: &a) {
      print("\n-----------  Struct with Struct ------------")
      printPointer(ptr: $0)
    }
  }
  
  func structWithProtocolValues() {
    struct SimpleStruct {
      let a: P
    }
    
    struct AStruct: P {
      func a() { }
    }
    
    var simpleStruct = SimpleStruct(a: AStruct())
    
    withUnsafePointer(to: &simpleStruct) {
      print("\n-----------  Struct with protocol values ------------")
      printPointer(ptr: $0)
    }
  }
  
  func simpleString() {
    var str = "1"
    
    withUnsafePointer(to: &str) {
      print("\n-----------  Simple String ------------")
      printPointer(ptr: $0)
    }
  }
}

