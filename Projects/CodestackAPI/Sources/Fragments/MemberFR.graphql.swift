// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct MemberFR: CodestackAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment MemberFR on Member { __typename email nickname username profileImage solvedProblems { __typename ...ProblemIdentityFR } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Member }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("email", String?.self),
    .field("nickname", String.self),
    .field("username", CodestackAPI.ID.self),
    .field("profileImage", String?.self),
    .field("solvedProblems", [SolvedProblem].self),
  ] }

  public var email: String? { __data["email"] }
  public var nickname: String { __data["nickname"] }
  public var username: CodestackAPI.ID { __data["username"] }
  public var profileImage: String? { __data["profileImage"] }
  public var solvedProblems: [SolvedProblem] { __data["solvedProblems"] }

  /// SolvedProblem
  ///
  /// Parent Type: `Problem`
  public struct SolvedProblem: CodestackAPI.SelectionSet {
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
}
