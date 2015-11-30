#' Get the shortest path between two nodes.
#' @param x A spgraph or a spresults object.
#' @export
getShortestPaths <- function(x, from=x$from, to=x$to) UseMethod("getShortestPaths")

#' @method getShortestPaths spresults
#' @param ... Additional arguments passed to \code{getShortestPaths.spgraph}
#' @describeIn getShortestPaths Get the shortest path given final spgraph.
#' @export
getShortestPaths.spresults <- function(x, from=x$from, to=x$to){
    graph <- x[[length(x)]]
    getShortestPaths.spgraph(graph, from=from, to=to)
}

#' @method getShortestPaths spgraph
#' @param from Source node
#' @param to Target node
#' @describeIn getShortestPaths Get the shortest path given the
#' knowledge of the provided spgraph instance.
#' @export
getShortestPaths.spgraph <- function(x, from=x$from, to=x$to) {
    graph <- x
    from <- get.vertex(graph, from)
    to <- get.vertex(graph, to)
    if(from == to){
        return(list(
            list(vertices=to, edges=NULL)
        ))
    }
    to_ <- to  # "to" is a reserved word in graph <3

    if(!(from$name %in% rownames(graph$shortest_path_predecessors))){
        stop("The spgraph has been generated using a single-source algorithm, but the given `from` parameter does not match the single source.")
    }

    predecessors <- graph$shortest_path_predecessors[[from$name, to_$name]]


    all <- list()
    # If you iterate over the predecessors directly, you die.
    # (You don't die. But the predecessors loose its type.)
    for(i in seq_along(predecessors)){
        p <- V(graph)[predecessors[i]]
        routes <- lapply(getShortestPaths.spgraph(graph, from, p), function(x) {
            edge <- E(graph)[p$name %->% to_$name]

            if(length(x$edges) == 0){
                edges <- edge
            } else {
                edges <- c(x$edges, edge)
            }

            list(
                vertices=c(x$vertices,to),
                edges=edges
            )
        })
        all <- c(all, routes)
    }
    all
}