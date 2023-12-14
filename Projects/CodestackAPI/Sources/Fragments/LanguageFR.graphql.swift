// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct LanguageFR: CodestackAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment LanguageFR on Language { __typename id name extension }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Language }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", CodestackAPI.ID.self),
    .field("name", String.self),
    .field("extension", String.self),
  ] }

  public var id: CodestackAPI.ID { __data["id"] }
  public var name: String { __data["name"] }
  public var `extension`: String { __data["extension"] }
}
