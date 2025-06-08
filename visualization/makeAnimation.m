function makeAnimation(S, tstepStart, tstepEnd, tstepSkip, isMovie)
    % Creates movie from solution struct S

    file = 'movie.mp4'; % .mp4 extension
    vid = VideoWriter(file, 'MPEG-4');
    vid.FrameRate = 2; % 10 frames per second

    % Open the video file
    open(vid);

    % Get final step
    % lastStep = size(S.Qs{1},2);

    % Generate and write frames
    for i=tstepStart:tstepSkip:tstepEnd
        % for r=1:length(S.Qs); plotRefAndDefGeom(S.Qs{r}(:,1), S.Qs{r}(:,i), r); end
        for r=1:length(S.Qs); plotRefAndDefGeom([], S.Qs{r}(:,i), r); end
        title(sprintf('Time = %.5f s, Step = %d', S.T(i), i))
        pause(0.1)
        frame = getframe(gcf);
        if isMovie==true; writeVideo(vid, frame); end
        clf
    end

    % Close the video file
    close(vid);

end