public protocol IDPCostEstimator {
    associatedtype Cost
    associatedtype Plan

    func cost(for plan: Plan) throws -> Cost
    func cost(_ cost: Cost, isCheaperThan other: Cost) -> Bool
}

public enum IDPPlannerError: Error {
    case unsatisfiableJoinError
    case unimplementedError
}

public protocol IDPPlanProvider {
    associatedtype Relation: Hashable
    associatedtype Plan
    associatedtype Estimator: IDPCostEstimator where Estimator.Plan == Plan
    
    var costEstimator: Estimator { get }
    func accessPlans(for: Relation) throws -> [Plan]
    func joinPlans<C: Collection, D: Collection>(_ lhs: C, _ rhs: D) throws -> [Plan] where C.Element == Plan, D.Element == Plan
    func prunePlans<C: Collection>(_ plans: C) throws -> [Plan] where C.Element == Plan
    func finalizePlans<C: Collection>(_ plans: C) throws -> [Plan] where C.Element == Plan
}

public struct IDPPlanner<I: IDPPlanProvider> {
    typealias TokenValue = Int
    enum IDPToken: Hashable {
        case relation(I.Relation)
        case symbol(TokenValue)
    }

    var provider: I
    var k: Int
    public init(_ provider: I, k: Int) {
        self.provider = provider
        self.k = k
    }
    
    public func join(_ relations: [I.Relation]) throws -> [I.Plan] {
        guard !relations.isEmpty else {
            throw IDPPlannerError.unsatisfiableJoinError
        }
        
        var nextToken = 0
        var optPlan = [Set<IDPToken>: [I.Plan]]()
        for relation in relations {
            let key = Set<IDPToken>([.relation(relation)])
            optPlan[key] = try provider.prunePlans(provider.accessPlans(for: relation))
        }
        
        var todo : Set<IDPToken> = Set(relations.map { .relation($0) })
        while todo.count > 1 {
            let k = min(self.k, todo.count)
            for i in 2...k {
                for s in todo.subsets(size: i) {
                    optPlan[s] = []
                    for o in s.allProperSubsets {
                        guard let opt_s = optPlan[s], let opt_o = optPlan[o], let opt_so = optPlan[s.subtracting(o)] else {
                            throw IDPPlannerError.unsatisfiableJoinError
                        }
                        
                        let plans = try  opt_s + provider.joinPlans(opt_o, opt_so)
                        let pruned = try provider.prunePlans(plans)
                        optPlan[s] = pruned
                    }
                }
            }

            // TODO:
            // find P, V with P \in optPlan(V), V proper subset of todo, |V| = k
            // such that eval(P) = min{eval(P') | P' \in optPlan(W), W proper subset of todo, |W| = k}
            var minCost : I.Estimator.Cost? = nil
            var minPlan : I.Plan? = nil
            var minSet : Set<IDPToken>? = nil
            for v in todo.subsets(size: k) {
                for p in optPlan[v, default: []] {
                    let cost = try provider.costEstimator.cost(for: p)
                    if let _minCost = minCost {
                        if provider.costEstimator.cost(cost, isCheaperThan: _minCost) {
                            minCost = cost
                            minPlan = p
                            minSet = v
                        }
                    } else {
                        minCost = cost
                        minPlan = p
                        minSet = v
                    }
                }
            }
            
            
            guard let p : I.Plan = minPlan, let v : Set<IDPToken> = minSet else {
                throw IDPPlannerError.unsatisfiableJoinError
            }
            
            let t = nextToken
            nextToken += 1
            let token = IDPToken.symbol(t)
//            print("generating new token for \(p)")
            
            optPlan[Set([token])] = [p]
            todo.insert(token)
            todo.subtract(v)
            
            
            for o in v.allProperSubsets {
                optPlan.removeValue(forKey: o)
            }
        }
        
        guard let plans = optPlan[todo] else {
            throw IDPPlannerError.unsatisfiableJoinError
        }
        
        let finalized = try provider.finalizePlans(plans)
        let pruned = try provider.prunePlans(finalized)
        return pruned
    }
}
