const mockErr = jest.fn();
jest.mock("i18next", () => ({ t: (i: string) => i }));
jest.mock("farmbot-toastr", () => ({ error: mockErr }));

import { commitBulkEditor } from "../actions";
import { fakeState } from "../../../__test_support__/fake_state";

describe("commitBulkEditor()", () => {
  it("does nothing if no regimen is selected", () => {
    const getState = () => fakeState();
    const dispatch = jest.fn();
    commitBulkEditor()(dispatch, getState);
    expect(dispatch.mock.calls.length).toEqual(0);
    expect(mockErr.mock.calls.length).toEqual(1);
  });
});
