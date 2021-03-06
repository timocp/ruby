# frozen_string_literal: true
require 'rubygems/resolver/molinillo/lib/molinillo/dependency_graph/action'
module Gem::Resolver::Molinillo
  class DependencyGraph
    # @!visibility private
    # @see DependencyGraph#detach_vertex_named
    class DetachVertexNamed < Action
      # @!group Action

      # (see Action#name)
      def self.name
        :add_vertex
      end

      # (see Action#up)
      def up(graph)
        return unless @vertex = graph.vertices.delete(name)
        @vertex.outgoing_edges.each do |e|
          v = e.destination
          v.incoming_edges.delete(e)
          graph.detach_vertex_named(v.name) unless v.root? || v.predecessors.any?
        end
        @vertex.incoming_edges.each do |e|
          v = e.origin
          v.outgoing_edges.delete(e)
        end
      end

      # (see Action#down)
      def down(graph)
        return unless @vertex
        graph.vertices[@vertex.name] = @vertex
        @vertex.outgoing_edges.each do |e|
          e.destination.incoming_edges << e
        end
        @vertex.incoming_edges.each do |e|
          e.origin.outgoing_edges << e
        end
      end

      # @!group DetachVertexNamed

      # @return [String] the name of the vertex to detach
      attr_reader :name

      # Initialize an action to detach a vertex from a dependency graph
      # @param [String] name the name of the vertex to detach
      def initialize(name)
        @name = name
      end
    end
  end
end
