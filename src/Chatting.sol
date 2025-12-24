// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

contract Chatting {
    struct Room {
        address[4] users;
        uint256 usersCount;
        bool status;
        bool exist;
    }

    mapping(address => bool) private _isChatting;

    uint256 private _chatId;
    mapping(uint256 => Room) private _chatByRoom;

    error AddressAlreadyChatting();
    error AddressDidntJoinChatYet();
    error ChatAlreadyCreated();
    error ChatAlreadyClosed();
    error InvalidChatId();
    error RoomIsFull();

    event JoinedChat(address indexed user, uint256 chatId);
    event ChatCreated(address indexed user, uint256 chatId);

    modifier isAddressChatting() {
        require(_isChatting[msg.sender] == false, AddressAlreadyChatting());
        _;
    }

    function createChatRoom() external isAddressChatting {
        _increaseChatId();
        _createChatRoom();
    }

    function joinChatByRoom(uint256 chatId) external isAddressChatting {
        _joinChatRoom(chatId);
    }

    
    function sendMessage() external {}

    function leaveChatRoom() external {
        require(_isChatting[msg.sender] = true, AddressDidntJoinChatYet());
        
        uint256 userJoinedChatId = _isChatting[msg.sender];
        // Room storage room = _chatByRoom[]
        // for(uint256 i = 0; i < )


        _isChatting[msg.sender] = false;
    }

    function _increaseChatId() private {
        ++_chatId;
    }

    function _createChatRoom() private {
        require(_chatByRoom[_chatId].status == false, ChatAlreadyCreated());

        Room storage room = _chatByRoom[_chatId];
        room.users[room.usersCount] = msg.sender;
        room.status = true;
        room.usersCount++;

        _isChatting[msg.sender] = true;

        emit ChatCreated(msg.sender, _chatId);
    }

    function _joinChatRoom(uint256 chatId) private {
        require(chatId <= _chatId && chatId > 0, InvalidChatId());

        Room storage room = _chatByRoom[chatId];

        require(room.status == true, ChatAlreadyClosed());
        require(room.usersCount < 4, RoomIsFull());

        _isChatting[msg.sender] = true;
        room.users[room.usersCount] = msg.sender;
        room.usersCount++;

        emit JoinedChat(msg.sender, chatId);
    }
}
