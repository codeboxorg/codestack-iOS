// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetAllLanguageQuery: GraphQLQuery {
  public static let operationName: String = "GetAllLanguage"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query GetAllLanguage {
        getAllLanguage {
          __typename
          id
          name
          extension
        }
      }
      """#
    ))

  public init() {}

  public struct Data: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getAllLanguage", [GetAllLanguage].self),
    ] }

    public var getAllLanguage: [GetAllLanguage] { __data["getAllLanguage"] }

    /// GetAllLanguage
    ///
    /// Parent Type: `Language`
    public struct GetAllLanguage: CodestackAPI.SelectionSet {
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
  }
}
