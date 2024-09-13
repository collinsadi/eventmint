// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// importing the ERC721 Interface which is IERC721, from open zeppelin

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// i call my event management platform EVENT MINT,
// because for every EVENT, you must have MINTed an NFT as a pass
// so that's the name EVENTMINT

/// @title an Event gated smart contract
/// @author Collins Adi

contract EventMintPlatform {
    // every event created on the platform
    // needs these informations

    // i used to answer this questions when registering for a tech event
    // they are mainly just for analytical purposes

    struct Attendee {
        address userAddress;
        string role; // maybe developer, designer, etc
        string howYouHeardAboutUs; // maybe twitter, a friend, facebook, etc.
        bool willBeAttendingPhysically; // to know if the user will be attending physically or not
    }

    struct Event {
        string name;
        uint256 date;
        address nftAddress;
        uint256 maxAttendees;
        Attendee[] participants;
    }

    // to keep track of the number of the events,
    // and also assign IDs from it.

    // i am making the event id 1, so there will be no event with an ID of 0

    uint256 public eventCount = 1;

    // a mapping to map id of an event to the details of the event
    // we are using mapping for easy access, instead of looping through arrays

    mapping(uint256 => Event) public events;

    // this is a 2d mapping of an event id to a mapping of an address
    // the adress will represent the user and to a bool which wil be
    // true or false if the user is registered or not (to the particular event with that id)

    mapping(uint256 => mapping(address => bool)) public registered;

    // event to emit when event is successfully created

    event EventCreated(
        uint256 eventId,
        string name,
        address nftContract,
        uint256 date
    );

    // event to emit when a users successfully registers
    event UserRegistered(uint256 eventId, address user);

    // this function allows us to create an event, so that other users
    // can register for the event
    function createEvent(
        string memory _name,
        uint256 _date,
        address _nftAddresss,
        uint256 _maxAttendees
    ) public {
        require(_nftAddresss != address(0), "Invalid NFT contract");

        Event storage newEvent = events[eventCount];
        newEvent.name = _name;
        newEvent.date = _date;
        newEvent.nftAddress = _nftAddresss;
        newEvent.maxAttendees = _maxAttendees;

        emit EventCreated(eventCount, _name, _nftAddresss, _date);
        eventCount++;
    }

    // this function allow users to tregister for an event,
    // this function does all the necessary checks
    // from checking if a user has the necessary nft or if they are already registered
    function registerForEvent(
        uint256 eventId,
        string memory _role,
        string memory _howYouHeardAboutUs,
        bool _willBeAttendingPhysically
    ) public {
        // her i am using "myEvent: as a variable name
        // because "event" is a reserved keyword in solidity

        Event storage myEvent = events[eventId];
        require(myEvent.date > block.timestamp, "Event has already happened");
        require(!registered[eventId][msg.sender], "User already registered");
        require(
            myEvent.participants.length < myEvent.maxAttendees,
            "Event is full"
        );

        // Check if the user owns the NFT required for the event
        require(
            IERC721(myEvent.nftAddress).balanceOf(msg.sender) > 0,
            "You don't own the required NFT"
        );

        myEvent.participants.push(
            Attendee({
                userAddress: msg.sender,
                role: _role,
                howYouHeardAboutUs: _howYouHeardAboutUs,
                willBeAttendingPhysically: _willBeAttendingPhysically
            })
        );
        registered[eventId][msg.sender] = true;

        emit UserRegistered(eventId, msg.sender);
    }

    // this function returns the array of all the addresses of all the participants
    // of a particular event event
    // will be necessary if the frontend wants to display it
    function getEventParticipants(
        uint256 eventId
    ) public view returns (Attendee[] memory) {
        return events[eventId].participants;
    }

    // this function is to get all the details of a particular event
    // using the event id
    function getEventDetails(
        uint256 eventId
    )
        public
        view
        returns (string memory, uint256, address, uint256, Attendee[] memory)
    {
        Event storage myEvent = events[eventId];
        return (
            myEvent.name,
            myEvent.date,
            myEvent.nftAddress,
            myEvent.maxAttendees,
            myEvent.participants
        );
    }
}
