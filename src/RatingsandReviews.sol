// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CueToken} from "./CueToken.sol";

/**
 * @title DecentralizedReviews
 * @notice This contract handles decentralized reviews, ratings, and user reputation management.
 * @author Kwesili Okafor
 */
contract RatingsandReviews is CueToken {
    error YOU_HAVE_RECIEVED_A_TOKEN();
    error DUPLICATE_REVIEW();

    // State Variables

    uint256 public reviewCount;
    CueToken public rewardToken;
    bool reviewSubmitted;
    bool receivedToken;
    uint256 private constant amount1 = 2000 * 10 ** 18;
    uint256 private constant amount2 = 100 * 10 ** 18;

    struct Review {
        address reviewer;
        address serviceProvider;
        uint8 rating;
        string comment;
        uint256 timestamp;
    }

    struct UserReputation {
        uint256 score;
        uint256 reviewCount;
        uint256[] penalties;
    }

    mapping(uint256 => Review) public reviews;
    mapping(address => mapping(uint256 => bool)) public hasReviewed;
    mapping(address => uint256[]) public serviceProviderReviews;
    mapping(address => UserReputation) public userReputations;
    mapping(address => bool) public isBanned;
    mapping(address => mapping(address => bool)) public hasReviewedProvider;

    // Events
    event ReviewSubmitted(
        uint256 reviewId,
        address reviewer,
        address serviceProvider,
        uint8 rating
    );
    event ReputationChanged(
        address indexed user,
        int256 change,
        uint256 newScore
    );
    event PenaltyApplied(address indexed user, uint256 penalty);

    // Constructor
    /**
     * @notice Constructor to initialize the contract with the reward token address.
    
     */

    constructor() {
        reviewCount = 0;
    }

    // External Functions

    /**
     * @notice Allows users to submit a review for a service provider.
    
     * @param _serviceProvider The address of the service provider.
     * @param _rating The rating given to the service provider (1-5).
     * @param _comment The comment for the review.
     */

    function submitReview(
        address _serviceProvider,
        uint8 _rating,
        string memory _comment
    ) external {
        require(_rating >= 1 && _rating <= 5, "Rating must be between 1 and 5");
        require(bytes(_comment).length <= 1000, "Comment too long");

        if (hasReviewedProvider[msg.sender][_serviceProvider]) {
            revert DUPLICATE_REVIEW();
        }
        uint256 reviewId = reviewCount++;
        Review storage newReview = reviews[reviewId];
        newReview.reviewer = msg.sender;
        newReview.serviceProvider = _serviceProvider;
        newReview.rating = _rating;
        newReview.comment = _comment;
        newReview.timestamp = block.timestamp;

        hasReviewed[msg.sender][reviewId] = true;
        hasReviewedProvider[msg.sender][_serviceProvider] = true;
        serviceProviderReviews[_serviceProvider].push(reviewId);

        // require(
        //     rewardToken.balanceOf(address(this)) >= amount1,
        //     "Insufficient contract balance"
        // );

        require(
            rewardToken.transfer(msg.sender, amount1),
            "Token transfer failed"
        );

        userReputations[msg.sender].reviewCount++;

        emit ReviewSubmitted(reviewId, msg.sender, _serviceProvider, _rating);
    }

    /**
     * @notice Retrieves the details of a specific review.
     * @param _reviewId The ID of the review.
     * @return reviewer The address of the reviewer.
     * @return serviceProvider The address of the service provider.
     * @return rating The rating given by the reviewer.
     * @return comment The review comment.
     * @return timestamp The timestamp of the review.
     */
    function getReview(
        uint256 _reviewId
    )
        external
        view
        returns (
            address reviewer,
            address serviceProvider,
            uint8 rating,
            string memory comment,
            uint256 timestamp
        )
    {
        Review storage review = reviews[_reviewId];
        return (
            review.reviewer,
            review.serviceProvider,
            review.rating,
            review.comment,
            review.timestamp
        );
    }

    /**
     * @notice Retrieves all review IDs for a specific service provider.
     * @param _serviceProvider The address of the service provider.
     * @return reviewIds The array of review IDs.
     */
    function getServiceProviderReviews(
        address _serviceProvider
    ) external view returns (uint256[] memory reviewIds) {
        return serviceProviderReviews[_serviceProvider];
    }

    /**
     * @notice Calculates the average rating for a specific service provider.
     * @param _serviceProvider The address of the service provider.
     * @return averageRating The average rating.
     */
    function getAverageRating(
        address _serviceProvider
    ) external view returns (uint8 averageRating) {
        uint256[] memory providerReviews = serviceProviderReviews[
            _serviceProvider
        ];
        if (providerReviews.length == 0) {
            return 0;
        }

        uint256 totalRating = 0;
        for (uint256 i = 0; i < providerReviews.length; i++) {
            totalRating += reviews[providerReviews[i]].rating;
        }

        return uint8(totalRating / providerReviews.length);
    }

    /**
     * @notice Increases the reputation score of a user.
     * @param _user The address of the user.
     * @param _amount The amount by which the reputation score is increased.
     */
    function increaseReputationScore(address _user, uint256 _amount) external {
        if (owner != msg.sender) {
            revert("YOU_ARE_NOT_THE_OWNER");
        }
        userReputations[_user].score += _amount;
        emit ReputationChanged(
            _user,
            int256(_amount),
            userReputations[_user].score
        );
    }

    /**
     * @notice Decreases the reputation score of a user.
     * @param _user The address of the user.
     * @param _amount The amount by which the reputation score is decreased.
     */
    function decreaseReputationScore(address _user, uint256 _amount) external {
        if (owner != msg.sender) {
            revert("YOU_ARE_NOT_THE_OWNER");
        }
        if (_amount > userReputations[_user].score) {
            userReputations[_user].score = 0;
        } else {
            userReputations[_user].score -= _amount;
        }
        emit ReputationChanged(
            _user,
            -int256(_amount),
            userReputations[_user].score
        );
    }

    /**
     * @notice Applies a penalty to a user and records it in their penalty history.
     * @param _user The address of the user.
     * @param _penalty The penalty to be applied.
     */
    function applyPenalty(address _user, uint256 _penalty) external {
        if (owner != msg.sender) {
            revert("YOU_ARE_NOT_THE_OWNER");
        }
        userReputations[_user].penalties.push(_penalty);
        emit PenaltyApplied(_user, _penalty);
    }

    /**
     * @notice Retrieves the penalty history of a user.
     * @param _user The address of the user.
     * @return penalties The array of penalties.
     */
    function getPenaltyHistory(
        address _user
    ) external view returns (uint256[] memory penalties) {
        return userReputations[_user].penalties;
    }

    /**
     * @notice Retrieves the trust level of a user based on their reputation score.
     * @param _user The address of the user.
     * @return trustLevel The trust level as a string.
     */

    function getTrustLevel(
        address _user
    ) external view returns (string memory trustLevel) {
        uint256 score = userReputations[_user].score;
        if (score >= 1000) {
            return "Very High";
        } else if (score >= 750) {
            return "High";
        } else if (score >= 500) {
            return "Medium";
        } else if (score >= 250) {
            return "Low";
        } else {
            return "Very Low";
        }
    }

    /**
     * @notice Allows the owner to delete a review.
     * @param _reviewId The ID of the review to be deleted.
     */
    function deleteReview(uint256 _reviewId) external {
        if (owner != msg.sender) {
            revert("YOU_ARE_NOT_THE_OWNER");
        }
        Review storage review = reviews[_reviewId];
        require(review.reviewer != address(0), "Review does not exist");

        uint256[] storage providerReviews = serviceProviderReviews[
            review.serviceProvider
        ];
        for (uint256 i = 0; i < providerReviews.length; i++) {
            if (providerReviews[i] == _reviewId) {
                providerReviews[i] = providerReviews[
                    providerReviews.length - 1
                ];
                providerReviews.pop();
                break;
            }
        }

        userReputations[review.reviewer].reviewCount--;

        delete reviews[_reviewId];
    }

    function transferTokensWhenSignedUp() public {
        if (receivedToken) {
            revert YOU_HAVE_RECIEVED_A_TOKEN();
        }

        _transfer(_msgSender(), msg.sender, amount2);
        receivedToken = true;
    }

    function getReviewCount() external view returns (uint256) {
        return reviewCount;
    }
}
