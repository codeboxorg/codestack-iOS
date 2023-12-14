// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchMeQuery: GraphQLQuery {
  public static let operationName: String = "FetchMe"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchMe { getMe { __typename ...MemberFR } }"#,
      fragments: [MemberFR.self, ProblemIdentityFR.self]
    ))

  public init() {}

  public struct Data: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getMe", GetMe.self),
    ] }

    public var getMe: GetMe { __data["getMe"] }

    /// GetMe
    ///
    /// Parent Type: `Member`
    public struct GetMe: CodestackAPI.SelectionSet {
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

      /// GetMe.SolvedProblem
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
