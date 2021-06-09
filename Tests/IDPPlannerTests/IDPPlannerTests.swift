import XCTest
@testable import IDPPlanner

struct Relation : Hashable {
    var name: String
    var scanCost: Double
}

struct Plan : Hashable, CustomStringConvertible {
    var name: String
    var children: [Plan]
    var description: String { return name }
}

struct Provider: IDPPlanProvider {
    struct Estimator: IDPCostEstimator {
        typealias Cost = Double
        var costs: [String: Double]

        init(costs: [String: Double]) {
            self.costs = costs
        }

        func cost(for plan: Plan) -> Cost {
            guard let cost = self.costs[plan.name] else {
                print("COST: \(plan.name)")
                return 1.0
            }
            return cost
        }
        
        func cost(_ cost: Cost, isCheaperThan other: Cost) -> Bool {
            return cost < other
        }
    }

    var costEstimator: Estimator
    init(costs: [String: Double]) {
        self.costEstimator = Estimator(costs: costs)
    }

    func accessPlans(for relation: Relation) -> [Plan] {
        return [
            Plan(name: "scan(\(relation.name))", children: []),
        ]
    }
    
    func joinPlans<C: Collection, D: Collection>(_ lhs: C, _ rhs: D) -> [Plan] where C.Element == Plan, D.Element == Plan {
        var plans = [Plan]()
        for l in lhs {
            for r in rhs {
                let name = "join(\(l.name)-\(r.name))"
                plans.append(contentsOf: [
                    Plan(name: name, children: [l, r]),
                ])
            }
        }
        return plans
    }
    
    func prunePlans<C: Collection>(_ plans: C) -> [Plan] where C.Element == Plan {
        return Array(plans)
    }
    
    func finalizePlans<C: Collection>(_ plans: C) -> [Plan] where C.Element == Plan {
        return Array(plans)
    }
}

final class IDPPlannerTests: XCTestCase {
    static var allTests = [
        ("test1", test1),
    ]

    func test1() throws {
        let costs : [String: Double] = [
            "join(scan(a)-scan(b))": 2.0,
            "join(scan(a)-scan(c))": 3.0,
            "join(scan(b)-scan(a))": 4.0,
            "join(scan(b)-scan(c))": 4.0,
            "join(scan(c)-scan(a))": 3.0,
            "join(scan(c)-scan(b))": 5.0,
            
            "join(join(scan(a)-scan(b))-scan(c))": 5.0,
            "join(scan(c)-join(scan(a)-scan(b)))": 5.1,
            "join(scan(b)-join(scan(a)-scan(c)))": 3.5,
            "join(scan(c)-join(scan(b)-scan(a)))": 6.0,
            
            "join(join(scan(b)-scan(a))-scan(c))": 6.0,
            "join(scan(a)-join(scan(b)-scan(c)))": 6.0,
            "join(scan(a)-join(scan(c)-scan(b)))": 7.0,
            "join(join(scan(b)-scan(c))-scan(a))": 6.0,
            "join(join(scan(c)-scan(b))-scan(a))": 7.0,
            "join(scan(b)-join(scan(c)-scan(a)))": 6.0,
            "join(join(scan(c)-scan(a))-scan(b))": 6.0,
            "join(join(scan(a)-scan(c))-scan(b))": 6.0,

        ]
        for k in [2, 3] {
            let provider = Provider(costs: costs)
            
            let idp = IDPPlanner(provider, k: k, blockSize: .bestPlan)
            let r1 = Relation(name: "a", scanCost: 2.0)
            let r2 = Relation(name: "b", scanCost: 5.0)
            let r3 = Relation(name: "c", scanCost: 3.0)

            let plans = try idp.join([r1, r2, r3])
            let p = plans.first!
            let cost = provider.costEstimator.cost(for: p)
            switch k {
            case 2:
                XCTAssertEqual(p.name, "join(join(scan(a)-scan(b))-scan(c))")
                XCTAssertEqual(cost, 5.0) // sub-optimal
            case 3:
                XCTAssertEqual(p.name, "join(scan(b)-join(scan(a)-scan(c)))")
                XCTAssertEqual(cost, 3.5)
            default:
                fatalError()
            }
        }
    }
}
