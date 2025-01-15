import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';

class GraphQLConfig {
  static String uri = 'http://172.16.10.64:5220/graphql';

  static final HttpLink httpLink = HttpLink(uri);

  static var client;

  static ValueNotifier<GraphQLClient> initializeClient() {
    final Link link = httpLink;

    final GraphQLClient client = GraphQLClient(
      link: link,
      cache: GraphQLCache(),
      defaultPolicies: DefaultPolicies(
        query: Policies(
          fetch: FetchPolicy.noCache,
        ),
        mutate: Policies(
          fetch: FetchPolicy.noCache,
        ),
        subscribe: Policies(
          fetch: FetchPolicy.noCache,
        ),
      ),
    );

    return ValueNotifier(client);
  }

  static Future<QueryResult> performQuery(String query, {Map<String, dynamic>? variables}) async {
    final GraphQLClient client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );

    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: variables ?? {},
    );

    try {
      final result = await client.query(options);
      if (result.hasException) {
        debugPrint('GraphQL Query Error: ${result.exception.toString()}');
      }
      return result;
    } catch (error) {
      debugPrint('GraphQL Error: $error');
      rethrow;
    }
  }

  static Future<QueryResult> performMutation(String mutation, {Map<String, dynamic>? variables}) async {
    final GraphQLClient client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: variables ?? {},
    );

    try {
      final result = await client.mutate(options);
      if (result.hasException) {
        debugPrint('GraphQL Mutation Error: ${result.exception.toString()}');
      }
      return result;
    } catch (error) {
      debugPrint('GraphQL Error: $error');
      rethrow;
    }
  }
}