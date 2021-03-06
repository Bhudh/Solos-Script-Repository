// BASIC WEAR/ANIMATE SCRIPT 1.0
// by Solo Mornington

// THIS NOTICE MUST REMAIN INTACT:
// Copyright 2010, Solo Mornington
// License: Use freely in any way you want. Modified versions
// may be used in any way. No credit or acknowledgement required.
// Definitive source and updates available here:
// http://github.com/SoloMornington/Solos-Script-Repository
// ** end notice

// A very basic framework script for others to modify
// hopefully illustrating some best-practices
//
// inspired by Catherine Omega's basic animation script on lslwiki.net

// WHAT THIS SCRIPT DOES:
// it plays an animation when the avatar wears the prim containing the script.
// it illustrates how to use the permissions system

// HOW TO USE IT:
// put this script in an object. this script should be in the root prim of the object
// change the next line to reflect the name of the animation you want to play

list gAnimations = [
    "[solo] karakasa spine lock",
    "[solo] shoulders up"
    ]; // what animation to play?

// NOTE: I use a naming convention of putting g at the start of any
// global variable. This makes it easier to see which variables have
// which scope.

default
{
    state_entry()
    {
        // when we come to state_entry, it can be from a number of different circumstances:
        // 1) the script has been reset
        // 2) the script has been edited
        // 3) the prim has been shift-drag copied
        // note that none of these have anything to do with being worn or removed.
        // but because we're probably going to be editing this script, and since the
        // user might reset it while wearing it, let's figure out if we're attached....
        if (llGetAttached())
        {
            // yes, we're attached, so we ask for permission to play animations.
            // which starts the whole cascade of permissions being given and
            // animation-playing. we also request the ability to take over the
            // controls, so that this script will stand a better chance of running
            // in no-script areas.
            llRequestPermissions(llGetOwner(),
                PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS);
        }
    }

    run_time_permissions(integer perm)
    {
        // handle the permissions change, in case the user resets the script
        // or the scripter is changing the script and doesn't want to detach/reattach
        // as part of the development cycle
        // or the object goes across a sim border
        // or the avatar teleports
        //
        // all other code leads here.
        // when the user does anything with this scripted object, it will
        // ask for permission to trigger animations.
        // this event will always fire when we ask permissions, even if
        // we already have those permissions.
        // therefore we only ever start animations here.
        if (perm & PERMISSION_TRIGGER_ANIMATION)
        {
            // yay we got permission, so let's start animating:
            integer i;
            integer count = llGetListLength(gAnimations);
            for(i=0; i<count; ++i)
            {
                llStartAnimation(llList2String(gAnimations, i));
            }
        }
        if (perm & PERMISSION_TAKE_CONTROLS)
        {
            // we only want to take control so the script keeps working
            // in no-script areas. so we don't accept anything and pass
            // on everything
            llTakeControls(CONTROL_ML_LBUTTON, FALSE, TRUE);
        }
    }

    attach(key id)
    {
        // this event is fired when the prim is either attached or detached.
        // this means the object could be worn, dropped, or pulled back into inventory
        // so let's figure out which:
        if (id != NULL_KEY) // if id isn't null then we're attached.
        {
            // ..so we ask permission to do animations, which will cause
            // run_time_permissions to fire.
            llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
        }
        else // if the object hasn't been attached, it's either dropped or in inventory
        {
            // this is our last chance to clean up after ourselves by
            // stopping the animation
            if (llGetPermissions() & PERMISSION_TRIGGER_ANIMATION)
            {
                integer i;
                integer count = llGetListLength(gAnimations);
                for(i=0; i<count; ++i)
                {
                    llStopAnimation(llList2String(gAnimations, i));
                }
            }
        }
    }
    
    changed(integer what)
    {
        // if we're being worn, and the avatar crosses a sim border, the new sim
        // will have no idea what animations should be playing. so we have to tell it.
        //
        // we're interested in the CHANGED_REGION flag, because we only need to tell
        // the new simulator what animation to play.
        // note that CHANGED_REGION will only happen in the *root* prim of a multi-prim
        // object. this places a few restrictions on how we script attachments.
        if (what & CHANGED_REGION)
        {
            // ok, we're in a new sim, so start up the animations again....
            llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
        }
    }
}