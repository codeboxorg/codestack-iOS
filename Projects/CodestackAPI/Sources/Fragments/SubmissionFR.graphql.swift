// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct SubmissionFR: CodestackAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment SubmissionFR on Submission { __typename id language { __typename ...LanguageFR } member { __typename username } memoryUsage problem { __typename ...ProblemIdentityFR } sourceCode cpuTime statusCode updatedAt createdAt }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Submission }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", CodestackAPI.ID.self),
    .field("language", Language.self),
    .field("member", Member.self),
    .field("memoryUsage", Double?.self),
    .field("problem", Problem.self),
    .field("sourceCode", String.self),
    .field("cpuTime", Double?.self),
    .field("statusCode", String?.self),
    .field("updatedAt", CodestackAPI.DateTime.self),
    .field("createdAt", CodestackAPI.DateTime.self),
  ] }

  public var id: CodestackAPI.ID { __data["id"] }
  public var language: Language { __data["language"] }
  public var member: Member { __data["member"] }
  public var memoryUsage: Double? { __data["memoryUsage"] }
  public var problem: Problem { __data["problem"] }
  public var sourceCode: String { __data["sourceCode"] }
  public var cpuTime: Double? { __data["cpuTime"] }
  public var statusCode: String? { __data["statusCode"] }
  public var updatedAt: CodestackAPI.DateTime { __data["updatedAt"] }
  public var createdAt: CodestackAPI.DateTime { __data["createdAt"] }

  /// Language
  ///
  /// Parent Type: `Language`
  public struct Language: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Language }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(LanguageFR.self),
    ] }

    public var id: CodestackAPI.ID { __data["id"] }
    public var name: String { __data["name"] }
    public var `extension`: String { __data["extension"] }

    public struct Fragments: FragmentContainer {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public var languageFR: LanguageFR { _toFragment() }
    }
  }

  /// Member
  ///
  /// Parent Type: `Member`
  public struct Member: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Member }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("username", CodestackAPI.ID.self),
    ] }

    public var username: CodestackAPI.ID { __data["username"] }
  }

  /// Problem
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
}
