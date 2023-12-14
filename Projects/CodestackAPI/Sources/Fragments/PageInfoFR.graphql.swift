// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct PageInfoFR: CodestackAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment PageInfoFR on PageInfo { __typename limit offset totalContent totalPage }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.PageInfo }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("limit", Int.self),
    .field("offset", Int.self),
    .field("totalContent", Int.self),
    .field("totalPage", Int.self),
  ] }

  public var limit: Int { __data["limit"] }
  public var offset: Int { __data["offset"] }
  public var totalContent: Int { __data["totalContent"] }
  public var totalPage: Int { __data["totalPage"] }
}
