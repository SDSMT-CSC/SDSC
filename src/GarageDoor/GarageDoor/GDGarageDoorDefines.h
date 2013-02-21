/**
 * Set of message values which can be passed to the garage door hardware, as
 * somewhat more human-readable.
 */
enum GD_MESSAGE_T
{
    /** @brief Not Acknowledged. Serial equivalent of logical false. */
    NAK=0,
    /** @brief Acknowledged. Used for handshakes and logical true. */
    ACK,
    /** @brief Open the door and respond NAK if door does not actually open. */
    OPEN,
    /** @brief Close the door and respond NAK if door does not actually close.*/
    CLOSE,
    /** @brief Query the door state; return ACK if open and NAK if closed. */
    IS_OPEN,
    /** @brief Query the door state; return ACK if closed and NAK if open. */
    IS_CLOSED,
    /** @brief Open the door and return ACK when open. */
    OPEN_IF_CLOSED,
    /** @brief Close the door and return ACK when closed, NAK iff error. */
    CLOSE_IF_OPEN,
    /** @brief Number of messages which can be passed to a garage door. This
     * should *ALWAYS* be the very last element, so if more messages are added,
     * they get added before this message. Note that you should NOT pass this
     * message to the hardware. */
    GD_MESSAGE_COUNT
};
