// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct ProblemIdentityFR: CodestackAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment ProblemIdentityFR on Problem { __typename id title }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Problem }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", CodestackAPI.ID.self),
    .field("title", String.self),
  ] }

  public var id: CodestackAPI.ID { __data["id"] }
  public var title: String { __data["title"] }
}
