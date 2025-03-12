function [nodeA, nodeB] = commonNode(tagA, pointsA, tagB, pointsB)
    % Returns the intersection nodes of the rods A and B
    % nodeA = intersecting node in rod A
    % nodeB = intersecting node in rod B

    % Find the common point
    [commNode, nodeA, nodeB] = intersect(pointsA, pointsB, 'rows');
    % nodeA and nodeB are actually the row indices in the pointsA and pointB matrix respectively
   
    % Check if pairs have common nodes    
    assert(~isempty(commNode), "Rod %d and %d do not intersect", tagA, tagB);

    % Check for single point intersection
    assert(size(commNode, 1) == 1, "Rod %d and %d intersect at multiple points", tagA, tagB);

    % Check for intersection at the ends (first node or the last node)
    isNodeAEndNode = (nodeA == 1 || nodeA == size(pointsA, 1)); % Checks if nodeA is at the either ends
    isNodeBEndNode = (nodeB == 1 || nodeB == size(pointsB, 1)); % Checks if nodeB is at the either ends
    
    assert(isNodeAEndNode && isNodeBEndNode, "Rod %d and %d do not intersect at ends", tagA, tagB);
      
end