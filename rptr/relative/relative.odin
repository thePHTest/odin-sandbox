package relative

import "core:intrinsics"

Ptr :: struct($T, $Backing: typeid,) where intrinsics.type_is_pointer(T) ||
	intrinsics.type_is_multi_pointer(T),
	intrinsics.type_is_integer(Backing)
{
	offset:
	Backing,
}

@(require_results)
decode :: proc "contextless" (ptr: ^$P/Ptr($T, $B)) -> T {
	if ptr.offset == 0 {
		return nil
	}
	p := int(uintptr(ptr)) + int(ptr.offset)
	return T(uintptr(p))
}

encode :: proc "contextless" (dst: ^$P/Ptr($T, $B), src: T) {
	if src == nil {
		dst.offset = 0
	} else {
		diff := int(uintptr(src)) - int(uintptr(dst))
		dst.offset = B(diff)
	}
}

Encode_Error :: enum {
	None,
	Overflow,
	Underflow,
	Self_Assign,
}

@(require_results)
encode_safe :: proc "contextless" (dst: ^$P/Ptr($T, $B), src: T) -> Encode_Error {
	if src == nil {
		dst.offset = 0
	} else {
		diff := int(uintptr(src)) - int(uintptr(dst))
		switch {
		case diff == 0:
			return .Self_Assign
		case diff > int(max(B)):
			return .Overflow
		case diff < int(min(B)):
			return .Underflow
		}
		dst.offset = B(diff)
	}
	return .None
}
