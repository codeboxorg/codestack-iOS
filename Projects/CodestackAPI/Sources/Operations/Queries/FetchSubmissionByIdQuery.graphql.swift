// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchSubmissionByIdQuery: GraphQLQuery {
  public static let operationName: String = "FetchSubmissionById"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchSubmissionById($id: ID!) { getSubmissionById(id: $id) { __typename id problem { __typename ...ProblemIdentityFR } member { __typename ...MemberFR } } }"#,
      fragments: [MemberFR.self, ProblemIdentityFR.self]
    ))

  public var id: ID

  public init(id: ID) {
    self.id = id
  }

  public var __variables: Variables? { ["id": id] }

  public struct Data: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getSubmissionById", GetSubmissionById.self, arguments: ["id": .variable("id")]),
    ] }

    public var getSubmissionById: GetSubmissionById { __data["getSubmissionById"] }

    /// GetSubmissionById
    ///
    /// Parent Type: `Submission`
    public struct GetSubmissionById: CodestackAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Submission }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", CodestackAPI.ID.self),
        .field("problem", Problem.self),
        .field("member", Member.self),
      ] }

      public var id: CodestackAPI.ID { __data["id"] }
      public var problem: Problem { __data["problem"] }
      public var member: Member { __data["member"] }

      /// GetSubmissionById.Problem
      ///
      /// Parent Type: `Problem`
      public struct Problem: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Problem }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ProblemIdentityFR.self),
        ] }

        public var id: CodestackAPI.ID { __data["id"] }
        public var title: String { __data["title"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var problemIdentityFR: ProblemIdentityFR { _toFragment() }
        }
      }

      /// GetSubmissionById.Member
      ///
      /// Parent Type: `Member`
      public struct Member: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Member }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(MemberFR.self),
        ] }

        public var email: String? { __data["email"] }
        public var nickname: String { __data["nickname"] }
        public var username: CodestackAPI.ID { __data["username"] }
        public var profileImage: String? { __data["profileImage"] }
        public var solvedProblems: [SolvedProblem] { __data["solvedProblems"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var memberFR: MemberFR { _toFragment() }
        }

        /// GetSubmissionById.Member.SolvedProblem
        ///
        /// Parent Type: `Problem`
        public struct SolvedProblem: CodestackAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Problem }

          public var id: CodestackAPI.ID { __data["id"] }
          public var title: String { __data["title"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var problemIdentityFR: ProblemIdentityFR { _toFragment() }
          }
        }
      }
    }
  }
}
