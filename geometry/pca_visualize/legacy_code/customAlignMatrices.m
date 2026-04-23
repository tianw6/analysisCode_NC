function [v_aligned, transformation] = customAlignMatrices(u, v, allow_reflection)
    % CUSTOMALIGNMATRICES Aligns matrix v to matrix u using manual Procrustes analysis
    % 
    % Inputs:
    %   u - Reference matrix (m x n)
    %   v - Matrix to be aligned (m x n)
    %   allow_reflection - Boolean flag to allow reflections (default: false)
    %
    % Outputs:
    %   v_aligned - Aligned version of v
    %   transformation - Structure containing transformation details
    
    % Set default value for allow_reflection if not provided
    if nargin < 3
        allow_reflection = false;
    end
    
    % Ensure matrices have the same size
    if ~isequal(size(u), size(v))
        error('Matrices u and v must have the same dimensions');
    end
    
    % Center the matrices (subtract mean)
    u_centered = u - mean(u(:));
    v_centered = v - mean(v(:));
    
    % Compute the cross-covariance matrix
    C = u_centered' * v_centered;
    
    % Singular Value Decomposition (SVD)
    [U, S, V] = svd(C);
    
    % Determine the optimal rotation matrix
    % This is the orthogonal transformation that maximizes the correlation
    R = V * U';
    
    % Check if we have a reflection (det(R) = -1)
    if det(R) < 0
        if allow_reflection
            % If reflections are allowed, keep R as is
            transformation_type = 'Rotation with reflection';
        else
            % Force a proper rotation (no reflection)
            % Modify the last column of V to ensure det(R) = 1
            V(:,end) = -V(:,end);
            R = V * U';
            transformation_type = 'Rotation only (reflection prevented)';
        end
    else
        transformation_type = 'Rotation only';
    end
    
    % Apply the transformation
    v_aligned = v_centered * R;
    
    % Add back the mean of u to match the scale
    v_aligned = v_aligned + mean(u(:));
    
    % Store transformation details
    transformation = struct();
    transformation.rotation_matrix = R;
    transformation.method = 'Custom Procrustes analysis';
    transformation.type = transformation_type;
    
    % Calculate alignment quality (correlation coefficient)
    similarity = corr2(u, v_aligned);
    transformation.similarity = similarity;
    
    fprintf('Alignment complete using custom Procrustes analysis.\n');
    fprintf('Transformation type: %s\n', transformation_type);
    fprintf('Correlation after alignment: %.4f\n', similarity);
end