// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct TagFR: CodestackAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment TagFR on Tag { __typename id name }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Tag }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", Double.self),
    .field("name", String.self),
  ] }

  public var id: Double { __data["id"] }
  public var name: String { __data["name"] }
}
