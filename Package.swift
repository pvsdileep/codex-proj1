// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HouseholdTasks",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "HouseholdTasks", targets: ["HouseholdTasks"]),
        .library(name: "HouseholdTasksWidget", targets: ["HouseholdTasksWidget"])
    ],
    targets: [
        .target(name: "HouseholdTasks", dependencies: [], path: "HouseholdTasks"),
        .target(name: "HouseholdTasksWidget", dependencies: ["HouseholdTasks"], path: "HouseholdTasksWidget"),
        .testTarget(name: "HouseholdTasksTests", dependencies: ["HouseholdTasks", "HouseholdTasksWidget"])
    ]
)
