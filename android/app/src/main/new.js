// var a = 20;
// console.log(a);
//  var a = 30;
//  console.log(a);

// var a=20;

// function printValues() {
//     const b = 10;
//     console.log(b);
// }
// printValues();

// let a = 10;
// console.log(a);
// console.log(typeof a);

// let b = "Hello";
// console.log(b);
// console.log(typeof b);

// let c = true;
// console.log(c);
// console.log(typeof c);

// let d=null;
// console.log(d);
// console.log(typeof d);  

// let e;
// console.log(typeof e);

// let a = 1000;
// let b = 1000;
// console.log(a == b); // true
// console.log(a === b); // false

// let age = 14;
// let res = age >=18 ? "can vote" : "you cannot vote";
// console.log(res);

// Named function expression
// function name() {
//     console.log("This is a named function expression");
// }
// name();

// function add(a, b) {
//     return a + b;
// }
// console.log(add(5, 10)); // 15

// ARROW FUNCTION
// let func() => {
//     console.log("This is an arrow function");
// }
// func();

let func = (a,b) => {
    let add = (a, b) => a + b;
    return add(a, b); 
}
console.log(func(10, 20));

//Special Behavior
let greet = () => {
    console.log("Welcome"); // Refers to the global object (window in browsers)
}
greet();