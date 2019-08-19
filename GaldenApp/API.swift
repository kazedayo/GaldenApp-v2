//  This file was automatically generated and should not be edited.

import Apollo

public enum ReplySorting: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case dateAsc
  case dateDesc
  case ratingTop
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "date_asc": self = .dateAsc
      case "date_desc": self = .dateDesc
      case "rating_top": self = .ratingTop
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .dateAsc: return "date_asc"
      case .dateDesc: return "date_desc"
      case .ratingTop: return "rating_top"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ReplySorting, rhs: ReplySorting) -> Bool {
    switch (lhs, rhs) {
      case (.dateAsc, .dateAsc): return true
      case (.dateDesc, .dateDesc): return true
      case (.ratingTop, .ratingTop): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ReplySorting] {
    return [
      .dateAsc,
      .dateDesc,
      .ratingTop,
    ]
  }
}

public enum UserGender: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case m
  case f
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "M": self = .m
      case "F": self = .f
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .m: return "M"
      case .f: return "F"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: UserGender, rhs: UserGender) -> Bool {
    switch (lhs, rhs) {
      case (.m, .m): return true
      case (.f, .f): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [UserGender] {
    return [
      .m,
      .f,
    ]
  }
}

public final class BlockUserMutation: GraphQLMutation {
  /// mutation BlockUser($id: String!) {
  ///   blockUser(id: $id)
  /// }
  public let operationDefinition =
    "mutation BlockUser($id: String!) { blockUser(id: $id) }"

  public let operationName = "BlockUser"

  public var id: String

  public init(id: String) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("blockUser", arguments: ["id": GraphQLVariable("id")], type: .nonNull(.scalar(Bool.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(blockUser: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "blockUser": blockUser])
    }

    public var blockUser: Bool {
      get {
        return resultMap["blockUser"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "blockUser")
      }
    }
  }
}

public final class UnblockUserMutation: GraphQLMutation {
  /// mutation UnblockUser($id: String!) {
  ///   unblockUser(id: $id)
  /// }
  public let operationDefinition =
    "mutation UnblockUser($id: String!) { unblockUser(id: $id) }"

  public let operationName = "UnblockUser"

  public var id: String

  public init(id: String) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("unblockUser", arguments: ["id": GraphQLVariable("id")], type: .nonNull(.scalar(Bool.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(unblockUser: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "unblockUser": unblockUser])
    }

    public var unblockUser: Bool {
      get {
        return resultMap["unblockUser"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "unblockUser")
      }
    }
  }
}

public final class ReplyThreadMutation: GraphQLMutation {
  /// mutation ReplyThread($threadId: Int!, $parentId: String, $html: String!) {
  ///   replyThread(threadId: $threadId, parentId: $parentId, html: $html) {
  ///     __typename
  ///     ...CommentsRecursive
  ///   }
  /// }
  public let operationDefinition =
    "mutation ReplyThread($threadId: Int!, $parentId: String, $html: String!) { replyThread(threadId: $threadId, parentId: $parentId, html: $html) { __typename ...CommentsRecursive } }"

  public let operationName = "ReplyThread"

  public var queryDocument: String { return operationDefinition.appending(CommentsRecursive.fragmentDefinition).appending(CommentFields.fragmentDefinition) }

  public var threadId: Int
  public var parentId: String?
  public var html: String

  public init(threadId: Int, parentId: String? = nil, html: String) {
    self.threadId = threadId
    self.parentId = parentId
    self.html = html
  }

  public var variables: GraphQLMap? {
    return ["threadId": threadId, "parentId": parentId, "html": html]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("replyThread", arguments: ["threadId": GraphQLVariable("threadId"), "parentId": GraphQLVariable("parentId"), "html": GraphQLVariable("html")], type: .nonNull(.object(ReplyThread.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(replyThread: ReplyThread) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "replyThread": replyThread.resultMap])
    }

    public var replyThread: ReplyThread {
      get {
        return ReplyThread(unsafeResultMap: resultMap["replyThread"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "replyThread")
      }
    }

    public struct ReplyThread: GraphQLSelectionSet {
      public static let possibleTypes = ["Reply"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(CommentsRecursive.self),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var commentsRecursive: CommentsRecursive {
          get {
            return CommentsRecursive(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}

public final class CreateThreadMutation: GraphQLMutation {
  /// mutation CreateThread($title: String!, $tags: [String!]!, $html: String!) {
  ///   createThread(title: $title, tags: $tags, html: $html)
  /// }
  public let operationDefinition =
    "mutation CreateThread($title: String!, $tags: [String!]!, $html: String!) { createThread(title: $title, tags: $tags, html: $html) }"

  public let operationName = "CreateThread"

  public var title: String
  public var tags: [String]
  public var html: String

  public init(title: String, tags: [String], html: String) {
    self.title = title
    self.tags = tags
    self.html = html
  }

  public var variables: GraphQLMap? {
    return ["title": title, "tags": tags, "html": html]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createThread", arguments: ["title": GraphQLVariable("title"), "tags": GraphQLVariable("tags"), "html": GraphQLVariable("html")], type: .nonNull(.scalar(Int.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createThread: Int) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "createThread": createThread])
    }

    public var createThread: Int {
      get {
        return resultMap["createThread"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "createThread")
      }
    }
  }
}

public final class GetChannelListQuery: GraphQLQuery {
  /// query GetChannelList {
  ///   channels {
  ///     __typename
  ///     ...ChannelDetails
  ///   }
  /// }
  public let operationDefinition =
    "query GetChannelList { channels { __typename ...ChannelDetails } }"

  public let operationName = "GetChannelList"

  public var queryDocument: String { return operationDefinition.appending(ChannelDetails.fragmentDefinition).appending(TagDetails.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("channels", type: .nonNull(.list(.nonNull(.object(Channel.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(channels: [Channel]) {
      self.init(unsafeResultMap: ["__typename": "Query", "channels": channels.map { (value: Channel) -> ResultMap in value.resultMap }])
    }

    public var channels: [Channel] {
      get {
        return (resultMap["channels"] as! [ResultMap]).map { (value: ResultMap) -> Channel in Channel(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: Channel) -> ResultMap in value.resultMap }, forKey: "channels")
      }
    }

    public struct Channel: GraphQLSelectionSet {
      public static let possibleTypes = ["Channel"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(ChannelDetails.self),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var channelDetails: ChannelDetails {
          get {
            return ChannelDetails(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}

public final class GetThreadsQuery: GraphQLQuery {
  /// query GetThreads($id: String!, $page: Int!) {
  ///   threadsByChannel(channelId: $id, page: $page) {
  ///     __typename
  ///     ...ThreadListDetails
  ///   }
  /// }
  public let operationDefinition =
    "query GetThreads($id: String!, $page: Int!) { threadsByChannel(channelId: $id, page: $page) { __typename ...ThreadListDetails } }"

  public let operationName = "GetThreads"

  public var queryDocument: String { return operationDefinition.appending(ThreadListDetails.fragmentDefinition).appending(TagDetails.fragmentDefinition) }

  public var id: String
  public var page: Int

  public init(id: String, page: Int) {
    self.id = id
    self.page = page
  }

  public var variables: GraphQLMap? {
    return ["id": id, "page": page]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("threadsByChannel", arguments: ["channelId": GraphQLVariable("id"), "page": GraphQLVariable("page")], type: .nonNull(.list(.nonNull(.object(ThreadsByChannel.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(threadsByChannel: [ThreadsByChannel]) {
      self.init(unsafeResultMap: ["__typename": "Query", "threadsByChannel": threadsByChannel.map { (value: ThreadsByChannel) -> ResultMap in value.resultMap }])
    }

    public var threadsByChannel: [ThreadsByChannel] {
      get {
        return (resultMap["threadsByChannel"] as! [ResultMap]).map { (value: ResultMap) -> ThreadsByChannel in ThreadsByChannel(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: ThreadsByChannel) -> ResultMap in value.resultMap }, forKey: "threadsByChannel")
      }
    }

    public struct ThreadsByChannel: GraphQLSelectionSet {
      public static let possibleTypes = ["Thread"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(ThreadListDetails.self),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var threadListDetails: ThreadListDetails {
          get {
            return ThreadListDetails(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}

public final class GetUserThreadsQuery: GraphQLQuery {
  /// query GetUserThreads($id: String!, $page: Int!) {
  ///   threadsByUser(userId: $id, page: $page) {
  ///     __typename
  ///     ...ThreadListDetails
  ///   }
  /// }
  public let operationDefinition =
    "query GetUserThreads($id: String!, $page: Int!) { threadsByUser(userId: $id, page: $page) { __typename ...ThreadListDetails } }"

  public let operationName = "GetUserThreads"

  public var queryDocument: String { return operationDefinition.appending(ThreadListDetails.fragmentDefinition).appending(TagDetails.fragmentDefinition) }

  public var id: String
  public var page: Int

  public init(id: String, page: Int) {
    self.id = id
    self.page = page
  }

  public var variables: GraphQLMap? {
    return ["id": id, "page": page]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("threadsByUser", arguments: ["userId": GraphQLVariable("id"), "page": GraphQLVariable("page")], type: .nonNull(.list(.nonNull(.object(ThreadsByUser.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(threadsByUser: [ThreadsByUser]) {
      self.init(unsafeResultMap: ["__typename": "Query", "threadsByUser": threadsByUser.map { (value: ThreadsByUser) -> ResultMap in value.resultMap }])
    }

    public var threadsByUser: [ThreadsByUser] {
      get {
        return (resultMap["threadsByUser"] as! [ResultMap]).map { (value: ResultMap) -> ThreadsByUser in ThreadsByUser(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: ThreadsByUser) -> ResultMap in value.resultMap }, forKey: "threadsByUser")
      }
    }

    public struct ThreadsByUser: GraphQLSelectionSet {
      public static let possibleTypes = ["Thread"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(ThreadListDetails.self),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var threadListDetails: ThreadListDetails {
          get {
            return ThreadListDetails(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}

public final class GetThreadContentQuery: GraphQLQuery {
  /// query GetThreadContent($id: Int!, $sorting: ReplySorting!, $page: Int!) {
  ///   thread(id: $id, sorting: $sorting, page: $page) {
  ///     __typename
  ///     id
  ///     title
  ///     totalReplies
  ///     replies {
  ///       __typename
  ///       ...CommentsRecursive
  ///     }
  ///     tags {
  ///       __typename
  ///       name
  ///       color
  ///     }
  ///   }
  /// }
  public let operationDefinition =
    "query GetThreadContent($id: Int!, $sorting: ReplySorting!, $page: Int!) { thread(id: $id, sorting: $sorting, page: $page) { __typename id title totalReplies replies { __typename ...CommentsRecursive } tags { __typename name color } } }"

  public let operationName = "GetThreadContent"

  public var queryDocument: String { return operationDefinition.appending(CommentsRecursive.fragmentDefinition).appending(CommentFields.fragmentDefinition) }

  public var id: Int
  public var sorting: ReplySorting
  public var page: Int

  public init(id: Int, sorting: ReplySorting, page: Int) {
    self.id = id
    self.sorting = sorting
    self.page = page
  }

  public var variables: GraphQLMap? {
    return ["id": id, "sorting": sorting, "page": page]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("thread", arguments: ["id": GraphQLVariable("id"), "sorting": GraphQLVariable("sorting"), "page": GraphQLVariable("page")], type: .object(Thread.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(thread: Thread? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "thread": thread.flatMap { (value: Thread) -> ResultMap in value.resultMap }])
    }

    public var thread: Thread? {
      get {
        return (resultMap["thread"] as? ResultMap).flatMap { Thread(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "thread")
      }
    }

    public struct Thread: GraphQLSelectionSet {
      public static let possibleTypes = ["Thread"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(Int.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("totalReplies", type: .nonNull(.scalar(Int.self))),
        GraphQLField("replies", type: .nonNull(.list(.nonNull(.object(Reply.selections))))),
        GraphQLField("tags", type: .nonNull(.list(.nonNull(.object(Tag.selections))))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: Int, title: String, totalReplies: Int, replies: [Reply], tags: [Tag]) {
        self.init(unsafeResultMap: ["__typename": "Thread", "id": id, "title": title, "totalReplies": totalReplies, "replies": replies.map { (value: Reply) -> ResultMap in value.resultMap }, "tags": tags.map { (value: Tag) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: Int {
        get {
          return resultMap["id"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return resultMap["title"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "title")
        }
      }

      public var totalReplies: Int {
        get {
          return resultMap["totalReplies"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "totalReplies")
        }
      }

      public var replies: [Reply] {
        get {
          return (resultMap["replies"] as! [ResultMap]).map { (value: ResultMap) -> Reply in Reply(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Reply) -> ResultMap in value.resultMap }, forKey: "replies")
        }
      }

      public var tags: [Tag] {
        get {
          return (resultMap["tags"] as! [ResultMap]).map { (value: ResultMap) -> Tag in Tag(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Tag) -> ResultMap in value.resultMap }, forKey: "tags")
        }
      }

      public struct Reply: GraphQLSelectionSet {
        public static let possibleTypes = ["Reply"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(CommentsRecursive.self),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var commentsRecursive: CommentsRecursive {
            get {
              return CommentsRecursive(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }

      public struct Tag: GraphQLSelectionSet {
        public static let possibleTypes = ["Tag"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("color", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String, color: String) {
          self.init(unsafeResultMap: ["__typename": "Tag", "name": name, "color": color])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        public var color: String {
          get {
            return resultMap["color"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "color")
          }
        }
      }
    }
  }
}

public final class GetBlockedUsersQuery: GraphQLQuery {
  /// query GetBlockedUsers {
  ///   blockedUsers {
  ///     __typename
  ///     id
  ///     nickname
  ///     avatar
  ///     gender
  ///     groups {
  ///       __typename
  ///       id
  ///       name
  ///     }
  ///   }
  /// }
  public let operationDefinition =
    "query GetBlockedUsers { blockedUsers { __typename id nickname avatar gender groups { __typename id name } } }"

  public let operationName = "GetBlockedUsers"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("blockedUsers", type: .nonNull(.list(.nonNull(.object(BlockedUser.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(blockedUsers: [BlockedUser]) {
      self.init(unsafeResultMap: ["__typename": "Query", "blockedUsers": blockedUsers.map { (value: BlockedUser) -> ResultMap in value.resultMap }])
    }

    public var blockedUsers: [BlockedUser] {
      get {
        return (resultMap["blockedUsers"] as! [ResultMap]).map { (value: ResultMap) -> BlockedUser in BlockedUser(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: BlockedUser) -> ResultMap in value.resultMap }, forKey: "blockedUsers")
      }
    }

    public struct BlockedUser: GraphQLSelectionSet {
      public static let possibleTypes = ["User"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(String.self))),
        GraphQLField("nickname", type: .nonNull(.scalar(String.self))),
        GraphQLField("avatar", type: .scalar(String.self)),
        GraphQLField("gender", type: .nonNull(.scalar(UserGender.self))),
        GraphQLField("groups", type: .nonNull(.list(.nonNull(.object(Group.selections))))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: String, nickname: String, avatar: String? = nil, gender: UserGender, groups: [Group]) {
        self.init(unsafeResultMap: ["__typename": "User", "id": id, "nickname": nickname, "avatar": avatar, "gender": gender, "groups": groups.map { (value: Group) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: String {
        get {
          return resultMap["id"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var nickname: String {
        get {
          return resultMap["nickname"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "nickname")
        }
      }

      public var avatar: String? {
        get {
          return resultMap["avatar"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "avatar")
        }
      }

      public var gender: UserGender {
        get {
          return resultMap["gender"]! as! UserGender
        }
        set {
          resultMap.updateValue(newValue, forKey: "gender")
        }
      }

      public var groups: [Group] {
        get {
          return (resultMap["groups"] as! [ResultMap]).map { (value: ResultMap) -> Group in Group(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Group) -> ResultMap in value.resultMap }, forKey: "groups")
        }
      }

      public struct Group: GraphQLSelectionSet {
        public static let possibleTypes = ["Group"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: String, name: String) {
          self.init(unsafeResultMap: ["__typename": "Group", "id": id, "name": name])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: String {
          get {
            return resultMap["id"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }
      }
    }
  }
}

public final class GetSessionUserQuery: GraphQLQuery {
  /// query GetSessionUser {
  ///   sessionUser {
  ///     __typename
  ///     id
  ///     nickname
  ///     avatar
  ///     gender
  ///     groups {
  ///       __typename
  ///       id
  ///       name
  ///     }
  ///     blockedUserIds
  ///   }
  /// }
  public let operationDefinition =
    "query GetSessionUser { sessionUser { __typename id nickname avatar gender groups { __typename id name } blockedUserIds } }"

  public let operationName = "GetSessionUser"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("sessionUser", type: .object(SessionUser.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(sessionUser: SessionUser? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "sessionUser": sessionUser.flatMap { (value: SessionUser) -> ResultMap in value.resultMap }])
    }

    public var sessionUser: SessionUser? {
      get {
        return (resultMap["sessionUser"] as? ResultMap).flatMap { SessionUser(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "sessionUser")
      }
    }

    public struct SessionUser: GraphQLSelectionSet {
      public static let possibleTypes = ["SessionUser"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(String.self))),
        GraphQLField("nickname", type: .nonNull(.scalar(String.self))),
        GraphQLField("avatar", type: .scalar(String.self)),
        GraphQLField("gender", type: .nonNull(.scalar(UserGender.self))),
        GraphQLField("groups", type: .nonNull(.list(.nonNull(.object(Group.selections))))),
        GraphQLField("blockedUserIds", type: .nonNull(.list(.nonNull(.scalar(String.self))))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: String, nickname: String, avatar: String? = nil, gender: UserGender, groups: [Group], blockedUserIds: [String]) {
        self.init(unsafeResultMap: ["__typename": "SessionUser", "id": id, "nickname": nickname, "avatar": avatar, "gender": gender, "groups": groups.map { (value: Group) -> ResultMap in value.resultMap }, "blockedUserIds": blockedUserIds])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: String {
        get {
          return resultMap["id"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var nickname: String {
        get {
          return resultMap["nickname"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "nickname")
        }
      }

      public var avatar: String? {
        get {
          return resultMap["avatar"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "avatar")
        }
      }

      public var gender: UserGender {
        get {
          return resultMap["gender"]! as! UserGender
        }
        set {
          resultMap.updateValue(newValue, forKey: "gender")
        }
      }

      public var groups: [Group] {
        get {
          return (resultMap["groups"] as! [ResultMap]).map { (value: ResultMap) -> Group in Group(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Group) -> ResultMap in value.resultMap }, forKey: "groups")
        }
      }

      public var blockedUserIds: [String] {
        get {
          return resultMap["blockedUserIds"]! as! [String]
        }
        set {
          resultMap.updateValue(newValue, forKey: "blockedUserIds")
        }
      }

      public struct Group: GraphQLSelectionSet {
        public static let possibleTypes = ["Group"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: String, name: String) {
          self.init(unsafeResultMap: ["__typename": "Group", "id": id, "name": name])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: String {
          get {
            return resultMap["id"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }
      }
    }
  }
}

public final class GetUserQuery: GraphQLQuery {
  /// query GetUser($id: String!) {
  ///   user(id: $id) {
  ///     __typename
  ///     id
  ///     nickname
  ///     avatar
  ///     gender
  ///     groups {
  ///       __typename
  ///       id
  ///       name
  ///     }
  ///   }
  /// }
  public let operationDefinition =
    "query GetUser($id: String!) { user(id: $id) { __typename id nickname avatar gender groups { __typename id name } } }"

  public let operationName = "GetUser"

  public var id: String

  public init(id: String) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("user", arguments: ["id": GraphQLVariable("id")], type: .object(User.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(user: User? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "user": user.flatMap { (value: User) -> ResultMap in value.resultMap }])
    }

    public var user: User? {
      get {
        return (resultMap["user"] as? ResultMap).flatMap { User(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "user")
      }
    }

    public struct User: GraphQLSelectionSet {
      public static let possibleTypes = ["User"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(String.self))),
        GraphQLField("nickname", type: .nonNull(.scalar(String.self))),
        GraphQLField("avatar", type: .scalar(String.self)),
        GraphQLField("gender", type: .nonNull(.scalar(UserGender.self))),
        GraphQLField("groups", type: .nonNull(.list(.nonNull(.object(Group.selections))))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: String, nickname: String, avatar: String? = nil, gender: UserGender, groups: [Group]) {
        self.init(unsafeResultMap: ["__typename": "User", "id": id, "nickname": nickname, "avatar": avatar, "gender": gender, "groups": groups.map { (value: Group) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: String {
        get {
          return resultMap["id"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var nickname: String {
        get {
          return resultMap["nickname"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "nickname")
        }
      }

      public var avatar: String? {
        get {
          return resultMap["avatar"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "avatar")
        }
      }

      public var gender: UserGender {
        get {
          return resultMap["gender"]! as! UserGender
        }
        set {
          resultMap.updateValue(newValue, forKey: "gender")
        }
      }

      public var groups: [Group] {
        get {
          return (resultMap["groups"] as! [ResultMap]).map { (value: ResultMap) -> Group in Group(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Group) -> ResultMap in value.resultMap }, forKey: "groups")
        }
      }

      public struct Group: GraphQLSelectionSet {
        public static let possibleTypes = ["Group"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: String, name: String) {
          self.init(unsafeResultMap: ["__typename": "Group", "id": id, "name": name])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: String {
          get {
            return resultMap["id"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }
      }
    }
  }
}

public final class GetIconPacksQuery: GraphQLQuery {
  /// query GetIconPacks {
  ///   installedPacks {
  ///     __typename
  ///     ...IconPacks
  ///   }
  /// }
  public let operationDefinition =
    "query GetIconPacks { installedPacks { __typename ...IconPacks } }"

  public let operationName = "GetIconPacks"

  public var queryDocument: String { return operationDefinition.appending(IconPacks.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("installedPacks", type: .nonNull(.list(.nonNull(.object(InstalledPack.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(installedPacks: [InstalledPack]) {
      self.init(unsafeResultMap: ["__typename": "Query", "installedPacks": installedPacks.map { (value: InstalledPack) -> ResultMap in value.resultMap }])
    }

    public var installedPacks: [InstalledPack] {
      get {
        return (resultMap["installedPacks"] as! [ResultMap]).map { (value: ResultMap) -> InstalledPack in InstalledPack(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: InstalledPack) -> ResultMap in value.resultMap }, forKey: "installedPacks")
      }
    }

    public struct InstalledPack: GraphQLSelectionSet {
      public static let possibleTypes = ["SmileyPack"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(IconPacks.self),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var iconPacks: IconPacks {
          get {
            return IconPacks(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}

public struct IconPacks: GraphQLFragment {
  /// fragment IconPacks on SmileyPack {
  ///   __typename
  ///   id
  ///   title
  ///   smilies {
  ///     __typename
  ///     id
  ///     alt
  ///     width
  ///     height
  ///   }
  /// }
  public static let fragmentDefinition =
    "fragment IconPacks on SmileyPack { __typename id title smilies { __typename id alt width height } }"

  public static let possibleTypes = ["SmileyPack"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("id", type: .nonNull(.scalar(String.self))),
    GraphQLField("title", type: .nonNull(.scalar(String.self))),
    GraphQLField("smilies", type: .nonNull(.list(.nonNull(.object(Smily.selections))))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(id: String, title: String, smilies: [Smily]) {
    self.init(unsafeResultMap: ["__typename": "SmileyPack", "id": id, "title": title, "smilies": smilies.map { (value: Smily) -> ResultMap in value.resultMap }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var id: String {
    get {
      return resultMap["id"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "id")
    }
  }

  public var title: String {
    get {
      return resultMap["title"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "title")
    }
  }

  public var smilies: [Smily] {
    get {
      return (resultMap["smilies"] as! [ResultMap]).map { (value: ResultMap) -> Smily in Smily(unsafeResultMap: value) }
    }
    set {
      resultMap.updateValue(newValue.map { (value: Smily) -> ResultMap in value.resultMap }, forKey: "smilies")
    }
  }

  public struct Smily: GraphQLSelectionSet {
    public static let possibleTypes = ["Smiley"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("id", type: .nonNull(.scalar(String.self))),
      GraphQLField("alt", type: .nonNull(.scalar(String.self))),
      GraphQLField("width", type: .nonNull(.scalar(Int.self))),
      GraphQLField("height", type: .nonNull(.scalar(Int.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(id: String, alt: String, width: Int, height: Int) {
      self.init(unsafeResultMap: ["__typename": "Smiley", "id": id, "alt": alt, "width": width, "height": height])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var id: String {
      get {
        return resultMap["id"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "id")
      }
    }

    public var alt: String {
      get {
        return resultMap["alt"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "alt")
      }
    }

    public var width: Int {
      get {
        return resultMap["width"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "width")
      }
    }

    public var height: Int {
      get {
        return resultMap["height"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "height")
      }
    }
  }
}

public struct ChannelDetails: GraphQLFragment {
  /// fragment ChannelDetails on Channel {
  ///   __typename
  ///   id
  ///   name
  ///   tags {
  ///     __typename
  ///     ...TagDetails
  ///   }
  /// }
  public static let fragmentDefinition =
    "fragment ChannelDetails on Channel { __typename id name tags { __typename ...TagDetails } }"

  public static let possibleTypes = ["Channel"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("id", type: .nonNull(.scalar(String.self))),
    GraphQLField("name", type: .nonNull(.scalar(String.self))),
    GraphQLField("tags", type: .nonNull(.list(.nonNull(.object(Tag.selections))))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(id: String, name: String, tags: [Tag]) {
    self.init(unsafeResultMap: ["__typename": "Channel", "id": id, "name": name, "tags": tags.map { (value: Tag) -> ResultMap in value.resultMap }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var id: String {
    get {
      return resultMap["id"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "id")
    }
  }

  public var name: String {
    get {
      return resultMap["name"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "name")
    }
  }

  public var tags: [Tag] {
    get {
      return (resultMap["tags"] as! [ResultMap]).map { (value: ResultMap) -> Tag in Tag(unsafeResultMap: value) }
    }
    set {
      resultMap.updateValue(newValue.map { (value: Tag) -> ResultMap in value.resultMap }, forKey: "tags")
    }
  }

  public struct Tag: GraphQLSelectionSet {
    public static let possibleTypes = ["Tag"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLFragmentSpread(TagDetails.self),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(id: String, name: String, color: String) {
      self.init(unsafeResultMap: ["__typename": "Tag", "id": id, "name": name, "color": color])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var tagDetails: TagDetails {
        get {
          return TagDetails(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }
}

public struct TagDetails: GraphQLFragment {
  /// fragment TagDetails on Tag {
  ///   __typename
  ///   id
  ///   name
  ///   color
  /// }
  public static let fragmentDefinition =
    "fragment TagDetails on Tag { __typename id name color }"

  public static let possibleTypes = ["Tag"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("id", type: .nonNull(.scalar(String.self))),
    GraphQLField("name", type: .nonNull(.scalar(String.self))),
    GraphQLField("color", type: .nonNull(.scalar(String.self))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(id: String, name: String, color: String) {
    self.init(unsafeResultMap: ["__typename": "Tag", "id": id, "name": name, "color": color])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var id: String {
    get {
      return resultMap["id"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "id")
    }
  }

  public var name: String {
    get {
      return resultMap["name"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "name")
    }
  }

  public var color: String {
    get {
      return resultMap["color"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "color")
    }
  }
}

public struct ThreadListDetails: GraphQLFragment {
  /// fragment ThreadListDetails on Thread {
  ///   __typename
  ///   id
  ///   title
  ///   replies {
  ///     __typename
  ///     author {
  ///       __typename
  ///       id
  ///     }
  ///     authorNickname
  ///     date
  ///   }
  ///   totalReplies
  ///   tags {
  ///     __typename
  ///     ...TagDetails
  ///   }
  /// }
  public static let fragmentDefinition =
    "fragment ThreadListDetails on Thread { __typename id title replies { __typename author { __typename id } authorNickname date } totalReplies tags { __typename ...TagDetails } }"

  public static let possibleTypes = ["Thread"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("id", type: .nonNull(.scalar(Int.self))),
    GraphQLField("title", type: .nonNull(.scalar(String.self))),
    GraphQLField("replies", type: .nonNull(.list(.nonNull(.object(Reply.selections))))),
    GraphQLField("totalReplies", type: .nonNull(.scalar(Int.self))),
    GraphQLField("tags", type: .nonNull(.list(.nonNull(.object(Tag.selections))))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(id: Int, title: String, replies: [Reply], totalReplies: Int, tags: [Tag]) {
    self.init(unsafeResultMap: ["__typename": "Thread", "id": id, "title": title, "replies": replies.map { (value: Reply) -> ResultMap in value.resultMap }, "totalReplies": totalReplies, "tags": tags.map { (value: Tag) -> ResultMap in value.resultMap }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var id: Int {
    get {
      return resultMap["id"]! as! Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "id")
    }
  }

  public var title: String {
    get {
      return resultMap["title"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "title")
    }
  }

  public var replies: [Reply] {
    get {
      return (resultMap["replies"] as! [ResultMap]).map { (value: ResultMap) -> Reply in Reply(unsafeResultMap: value) }
    }
    set {
      resultMap.updateValue(newValue.map { (value: Reply) -> ResultMap in value.resultMap }, forKey: "replies")
    }
  }

  public var totalReplies: Int {
    get {
      return resultMap["totalReplies"]! as! Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "totalReplies")
    }
  }

  public var tags: [Tag] {
    get {
      return (resultMap["tags"] as! [ResultMap]).map { (value: ResultMap) -> Tag in Tag(unsafeResultMap: value) }
    }
    set {
      resultMap.updateValue(newValue.map { (value: Tag) -> ResultMap in value.resultMap }, forKey: "tags")
    }
  }

  public struct Reply: GraphQLSelectionSet {
    public static let possibleTypes = ["Reply"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("author", type: .nonNull(.object(Author.selections))),
      GraphQLField("authorNickname", type: .nonNull(.scalar(String.self))),
      GraphQLField("date", type: .nonNull(.scalar(String.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(author: Author, authorNickname: String, date: String) {
      self.init(unsafeResultMap: ["__typename": "Reply", "author": author.resultMap, "authorNickname": authorNickname, "date": date])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var author: Author {
      get {
        return Author(unsafeResultMap: resultMap["author"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "author")
      }
    }

    public var authorNickname: String {
      get {
        return resultMap["authorNickname"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "authorNickname")
      }
    }

    public var date: String {
      get {
        return resultMap["date"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "date")
      }
    }

    public struct Author: GraphQLSelectionSet {
      public static let possibleTypes = ["User"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: String) {
        self.init(unsafeResultMap: ["__typename": "User", "id": id])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: String {
        get {
          return resultMap["id"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }
    }
  }

  public struct Tag: GraphQLSelectionSet {
    public static let possibleTypes = ["Tag"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLFragmentSpread(TagDetails.self),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(id: String, name: String, color: String) {
      self.init(unsafeResultMap: ["__typename": "Tag", "id": id, "name": name, "color": color])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var tagDetails: TagDetails {
        get {
          return TagDetails(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }
}

public struct CommentsRecursive: GraphQLFragment {
  /// fragment CommentsRecursive on Reply {
  ///   __typename
  ///   ...CommentFields
  ///   parent {
  ///     __typename
  ///     ...CommentFields
  ///     parent {
  ///       __typename
  ///       ...CommentFields
  ///       parent {
  ///         __typename
  ///         ...CommentFields
  ///         parent {
  ///           __typename
  ///           ...CommentFields
  ///         }
  ///       }
  ///     }
  ///   }
  /// }
  public static let fragmentDefinition =
    "fragment CommentsRecursive on Reply { __typename ...CommentFields parent { __typename ...CommentFields parent { __typename ...CommentFields parent { __typename ...CommentFields parent { __typename ...CommentFields } } } } }"

  public static let possibleTypes = ["Reply"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLFragmentSpread(CommentFields.self),
    GraphQLField("parent", type: .object(Parent.selections)),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var parent: Parent? {
    get {
      return (resultMap["parent"] as? ResultMap).flatMap { Parent(unsafeResultMap: $0) }
    }
    set {
      resultMap.updateValue(newValue?.resultMap, forKey: "parent")
    }
  }

  public var fragments: Fragments {
    get {
      return Fragments(unsafeResultMap: resultMap)
    }
    set {
      resultMap += newValue.resultMap
    }
  }

  public struct Fragments {
    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public var commentFields: CommentFields {
      get {
        return CommentFields(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }
  }

  public struct Parent: GraphQLSelectionSet {
    public static let possibleTypes = ["Reply"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLFragmentSpread(CommentFields.self),
      GraphQLField("parent", type: .object(Parent.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var parent: Parent? {
      get {
        return (resultMap["parent"] as? ResultMap).flatMap { Parent(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "parent")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var commentFields: CommentFields {
        get {
          return CommentFields(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }

    public struct Parent: GraphQLSelectionSet {
      public static let possibleTypes = ["Reply"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(CommentFields.self),
        GraphQLField("parent", type: .object(Parent.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var parent: Parent? {
        get {
          return (resultMap["parent"] as? ResultMap).flatMap { Parent(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "parent")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var commentFields: CommentFields {
          get {
            return CommentFields(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct Parent: GraphQLSelectionSet {
        public static let possibleTypes = ["Reply"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(CommentFields.self),
          GraphQLField("parent", type: .object(Parent.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var parent: Parent? {
          get {
            return (resultMap["parent"] as? ResultMap).flatMap { Parent(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "parent")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var commentFields: CommentFields {
            get {
              return CommentFields(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct Parent: GraphQLSelectionSet {
          public static let possibleTypes = ["Reply"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(CommentFields.self),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var commentFields: CommentFields {
              get {
                return CommentFields(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }
      }
    }
  }
}

public struct CommentFields: GraphQLFragment {
  /// fragment CommentFields on Reply {
  ///   __typename
  ///   id
  ///   floor
  ///   author {
  ///     __typename
  ///     id
  ///     avatar
  ///     nickname
  ///     gender
  ///     groups {
  ///       __typename
  ///       id
  ///       name
  ///     }
  ///   }
  ///   authorNickname
  ///   parentId
  ///   content
  ///   date
  /// }
  public static let fragmentDefinition =
    "fragment CommentFields on Reply { __typename id floor author { __typename id avatar nickname gender groups { __typename id name } } authorNickname parentId content date }"

  public static let possibleTypes = ["Reply"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("id", type: .nonNull(.scalar(String.self))),
    GraphQLField("floor", type: .nonNull(.scalar(Int.self))),
    GraphQLField("author", type: .nonNull(.object(Author.selections))),
    GraphQLField("authorNickname", type: .nonNull(.scalar(String.self))),
    GraphQLField("parentId", type: .scalar(String.self)),
    GraphQLField("content", type: .nonNull(.scalar(String.self))),
    GraphQLField("date", type: .nonNull(.scalar(String.self))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(id: String, floor: Int, author: Author, authorNickname: String, parentId: String? = nil, content: String, date: String) {
    self.init(unsafeResultMap: ["__typename": "Reply", "id": id, "floor": floor, "author": author.resultMap, "authorNickname": authorNickname, "parentId": parentId, "content": content, "date": date])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var id: String {
    get {
      return resultMap["id"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "id")
    }
  }

  public var floor: Int {
    get {
      return resultMap["floor"]! as! Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "floor")
    }
  }

  public var author: Author {
    get {
      return Author(unsafeResultMap: resultMap["author"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "author")
    }
  }

  public var authorNickname: String {
    get {
      return resultMap["authorNickname"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "authorNickname")
    }
  }

  public var parentId: String? {
    get {
      return resultMap["parentId"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "parentId")
    }
  }

  public var content: String {
    get {
      return resultMap["content"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "content")
    }
  }

  public var date: String {
    get {
      return resultMap["date"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "date")
    }
  }

  public struct Author: GraphQLSelectionSet {
    public static let possibleTypes = ["User"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("id", type: .nonNull(.scalar(String.self))),
      GraphQLField("avatar", type: .scalar(String.self)),
      GraphQLField("nickname", type: .nonNull(.scalar(String.self))),
      GraphQLField("gender", type: .nonNull(.scalar(UserGender.self))),
      GraphQLField("groups", type: .nonNull(.list(.nonNull(.object(Group.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(id: String, avatar: String? = nil, nickname: String, gender: UserGender, groups: [Group]) {
      self.init(unsafeResultMap: ["__typename": "User", "id": id, "avatar": avatar, "nickname": nickname, "gender": gender, "groups": groups.map { (value: Group) -> ResultMap in value.resultMap }])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var id: String {
      get {
        return resultMap["id"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "id")
      }
    }

    public var avatar: String? {
      get {
        return resultMap["avatar"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "avatar")
      }
    }

    public var nickname: String {
      get {
        return resultMap["nickname"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "nickname")
      }
    }

    public var gender: UserGender {
      get {
        return resultMap["gender"]! as! UserGender
      }
      set {
        resultMap.updateValue(newValue, forKey: "gender")
      }
    }

    public var groups: [Group] {
      get {
        return (resultMap["groups"] as! [ResultMap]).map { (value: ResultMap) -> Group in Group(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: Group) -> ResultMap in value.resultMap }, forKey: "groups")
      }
    }

    public struct Group: GraphQLSelectionSet {
      public static let possibleTypes = ["Group"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: String, name: String) {
        self.init(unsafeResultMap: ["__typename": "Group", "id": id, "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: String {
        get {
          return resultMap["id"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }
    }
  }
}
