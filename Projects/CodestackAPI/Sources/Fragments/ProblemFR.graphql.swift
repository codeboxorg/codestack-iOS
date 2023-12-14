// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct ProblemFR: CodestackAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment ProblemFR on Problem { __typename id title context languages { __typename ...LanguageFR } tags { __typename ...TagFR } accepted submission maxCpuTime maxMemory }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Problem }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", CodestackAPI.ID.self),
    .field("title", String.self),
    .field("context", String.self),
    .field("languages", [Language].self),
    .field("tags", [Tag].self),
    .field("accepted", Double.self),
    .field("submission", Double.self),
    .field("maxCpuTime", String.self),
    .field("maxMemory", Double.self),
  ] }

  public var id: CodestackAPI.ID { __data["id"] }
  public var title: String { __data["title"] }
  public var context: String { __data["context"] }
  public var languages: [Language] { __data["languages"] }
  public var tags: [Tag] { __data["tags"] }
  public var accepted: Double { __data["accepted"] }
  public var submission: Double { __data["submission"] }
  public var maxCpuTime: String { __data["maxCpuTime"] }
  public var maxMemory: Double { __data["maxMemory"] }

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

  /// Tag
  ///
  /// Parent Type: `Tag`
  public struct Tag: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Tag }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(TagFR.self),
    ] }

    public var id: Double { __data["id"] }
    public var name: String { __data["name"] }

    public struct Fragments: FragmentContainer {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public var tagFR: TagFR { _toFragment() }
    }
  }
}
